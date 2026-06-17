$fn = 160;

// Requested dimensions (mm)
shaft_diameter = 6.0;     // major diameter (M6)
shaft_length   = 10.0;    // under-head length
head_diameter  = 10.5;
head_height    = 3.3;     // dome height above head base plane (z=0)

// Simple drive feature
drive_depth = 1.2;
drive_width = 1.6;

// Thread approximation (visual helical thread)
thread_pitch = 1.0;       // M6 coarse pitch
thread_depth = 0.35;      // radial depth of thread (visual)
thread_starts = 1;

// Small overlap to guarantee watertight unions/differences
eps = 0.03;

// Derived
shaft_r = shaft_diameter/2;
head_r  = head_diameter/2;

// Spherical-cap dome: sphere radius that yields given base radius and cap height
// R = (a^2 + h^2) / (2h)
cap_R = (head_r*head_r + head_height*head_height) / (2*head_height);

// Z location of sphere center so that cap base is at z=0 and top at z=head_height
cap_center_z = head_height - cap_R;

module dome_head_cap() {
    intersection() {
        translate([0, 0, cap_center_z]) sphere(r = cap_R);
        translate([0, 0, head_height/2])
            cylinder(h = head_height + eps, r = head_r, center = true);
    }
}

module drive_slot() {
    translate([0, 0, head_height - drive_depth/2])
        union() {
            cube([head_diameter*0.75, drive_width, drive_depth + eps], center = true);
            cube([drive_width, head_diameter*0.75, drive_depth + eps], center = true);
        }
}

// Helical thread ridge (approximation) wrapped around a core cylinder.
// Produces a single connected solid when unioned with the core.
module threaded_shank(major_d=6.0, length=10.0, pitch=1.0, depth=0.35, starts=1) {
    major_r = major_d/2;
    core_r  = max(major_r - depth, 0.01);

    // Core (minor diameter cylinder)
    union() {
        // Core from z=-length to z=0
        translate([0, 0, -length])
            cylinder(h = length + eps, r = core_r);

        // Helical ridge(s)
        for (s = [0:starts-1]) {
            rotate([0, 0, s*360/starts])
                translate([0, 0, -length])
                    linear_extrude(
                        height = length + eps,
                        twist  = 360*(length/pitch),
                        slices = max(ceil((length/pitch)*40), 80),
                        convexity = 10
                    )
                    // Place a small rectangle at the major radius so it becomes a ridge
                    // that touches the core (ensures connectivity).
                    translate([core_r - eps, -pitch*0.18])
                        square([ (major_r - core_r) + eps, pitch*0.36 ]);
        }
    }
}

module screw_body() {
    union() {
        // Threaded shank from z=-shaft_length to z=0
        threaded_shank(
            major_d = shaft_diameter,
            length  = shaft_length,
            pitch   = thread_pitch,
            depth   = thread_depth,
            starts  = thread_starts
        );

        // Dome head from z=0 to z=head_height
        dome_head_cap();
    }
}

difference() {
    screw_body();
    drive_slot();
}