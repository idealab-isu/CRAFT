$fn = 120;

// Target dimensions (mm)
shaft_diameter = 3.0;
shaft_length   = 10.0;   // under-head length
head_diameter  = 5.7;
head_height    = 1.65;

// Simple thread approximation (visual)
thread_pitch   = 0.6;    // mm
thread_depth   = 0.18;   // radial mm (kept small so major dia stays near 3.0)

// Optional hex socket (set depth=0 to disable)
hex_socket_flat_d = 2.0; // across flats (approx)
hex_socket_depth  = 1.0;

// Small overlaps to ensure watertight unions/differences
eps = 0.02;

// Structural overlap to guarantee physical attachment (1–2mm as required)
overlap_z = 1.0;

function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// 2D profile for a dome head with exact head_diameter and head_height.
// Uses a spherical cap that meets the base at z=0 and apex at z=head_height.
module dome_head_solid() {
    r = head_diameter/2;
    h = head_height;

    // Sphere radius that yields a cap of height h on base radius r:
    // R = (r^2 + h^2) / (2h)
    R = (r*r + h*h) / (2*h);

    // Sphere center relative to base plane z=0 is at z = h - R (negative)
    zc = h - R;

    rotate_extrude(convexity=10)
        intersection() {
            translate([0, zc]) circle(r=R);
            square([r, h], center=false);
        }
}

// Approximate external thread by adding a shallow helical ridge to a core cylinder.
module threaded_shaft() {
    major_r = shaft_diameter/2;
    core_r  = major_r - thread_depth;
    core_r  = core_r < 0.1 ? 0.1 : core_r;

    union() {
        // Core
        cylinder(r=core_r, h=shaft_length, center=false);

        // Helical ridge (approx thread)
        turns = shaft_length / thread_pitch;
        linear_extrude(
            height=shaft_length,
            twist=turns*360,
            slices=max(ceil(turns*40), 60),
            center=false,
            convexity=10
        )
            translate([core_r, 0, 0])
                square([thread_depth, thread_pitch*0.45], center=true);
    }
}

// Hex socket recess (true hex prism) cut into the head from the top.
module hex_socket_recess() {
    if (hex_socket_depth > 0) {
        // AF = 2 * R * cos(30) => R = AF / (2*cos30)
        R = hex_socket_flat_d / (2*cos(30));

        // Cut from the top of the head downward; extend slightly for clean boolean
        translate([0, 0, shaft_length + head_height - hex_socket_depth - eps])
            cylinder(r=R, h=hex_socket_depth + 2*eps, $fn=6, center=false);
    }
}

module screw() {
    difference() {
        union() {
            // Shaft from z=0..shaft_length
            threaded_shaft();

            // Head base plane is z=0 in dome_head_solid().
            // Place it so it overlaps the shaft by 1mm to guarantee attachment.
            // Head base at z = shaft_length - overlap_z
            translate([0, 0, shaft_length - overlap_z])
                dome_head_solid();

            // Add a small hidden "neck" cylinder inside the head to ensure robust union
            // even if the thread ridge/core doesn't perfectly meet the dome underside.
            // This does not change the visible design (it's fully inside the head).
            neck_r = (shaft_diameter/2) - 0.01;
            translate([0, 0, shaft_length - overlap_z])
                cylinder(r=neck_r, h=overlap_z + eps, center=false);
        }

        // Socket cut
        hex_socket_recess();
    }
}

screw();