// Dome head screw: 2.5mm shank dia, 10mm overall length,
// 5.35mm head dia, 1.6mm head height (spherical cap)
// One connected solid with simple helical thread approximation.

$fn = 128;

// --- Parameters (mm) ---
shaft_diameter = 2.5;
overall_length = 10;
head_diameter  = 5.35;
head_height    = 1.6;

// Thread (visual approximation)
thread_pitch = 0.5;
thread_depth = 0.18;   // radial height of thread ridge
thread_width = 0.22;   // tangential thickness of ridge

// Derived
shaft_length = overall_length - head_height;
shaft_r = shaft_diameter/2;
head_r  = head_diameter/2;

// Spherical cap geometry for dome head:
// cap height = head_height, base radius = head_r
// sphere radius R = (a^2 + h^2) / (2h)
cap_h = head_height;
cap_a = head_r;
sphere_R = (cap_a*cap_a + cap_h*cap_h) / (2*cap_h);

// Place cap so its base plane is exactly at z=shaft_length
sphere_center_z = shaft_length + (cap_h - sphere_R);

// Small overlap to guarantee watertight union
eps = 0.03;

// --- Modules ---
module shank_core() {
    // Shank from z=0 to z=shaft_length, with slight overlap into head
    cylinder(h=shaft_length + eps, r=shaft_r, center=false);
}

module thread_ridge() {
    // Helical ridge wrapped around shank (unioned, not subtracted)
    turns = shaft_length / thread_pitch;
    linear_extrude(
        height = shaft_length + eps,
        twist  = turns * 360,
        slices = max(ceil(turns * 60), 120),
        center = false
    )
        translate([shaft_r - thread_depth, 0, 0])
            square([thread_depth, thread_width], center=false);
}

module dome_head() {
    // Spherical cap clipped to exact head height and diameter
    intersection() {
        translate([0, 0, sphere_center_z]) sphere(r=sphere_R);
        translate([0, 0, shaft_length - eps])
            cylinder(h=head_height + 2*eps, r=head_r, center=false);
    }
}

module dome_head_screw() {
    // Ensure the model is oriented along +Z so orthographic views show length
    union() {
        shank_core();
        thread_ridge();
        dome_head();
    }
}

// Render
dome_head_screw();