$fn = 96;

// Requested dimensions (mm)
shaft_diameter = 5.0;
overall_length  = 10.0;
head_diameter   = 9.5;
head_height     = 2.75;

// Derived
shaft_length = overall_length - head_height;

// Drive (simple Phillips-style cross recess)
drive_depth = 1.6;                 // recess depth into head
drive_width = 1.2;                 // slot width
drive_len   = head_diameter * 0.72; // slot length across head
drive_taper = 0.35;                // slight taper for nicer look

// Thread (visual approximation)
pitch = 1.0;                       // mm per turn (approx)
thread_depth = 0.35;               // radial depth of thread
thread_turns = shaft_length / pitch;

eps = 0.02;

// Dome head as a spherical cap with exact base diameter and height
module dome_head_cap(d_base, h_cap) {
    r = (h_cap*h_cap + (d_base/2)*(d_base/2)) / (2*h_cap); // sphere radius for cap
    zc = h_cap - r;                                        // sphere center z relative to cap base plane

    intersection() {
        translate([0,0,zc]) sphere(r=r);
        cylinder(h=h_cap, d=d_base, center=false);
    }
}

// Simple helical thread (approx) using linear_extrude twist
module threaded_shaft(d_major, len, pitch, depth) {
    d_minor = d_major - 2*depth;

    union() {
        // Core
        cylinder(h=len, d=d_minor, center=false);

        // Helical ridge
        linear_extrude(height=len, twist=360*(len/pitch), slices=max(ceil(len*12), 60), convexity=10)
            translate([d_minor/2, 0, 0])
                circle(r=depth, $fn=24);
    }
}

// Phillips-like cross recess (two perpendicular tapered slots)
module phillips_recess(depth, width, len, taper) {
    // Cut from the top of the head downward
    translate([0,0,head_height - depth])
    union() {
        // Slot 1
        linear_extrude(height=depth + eps, scale=1 + taper, convexity=5)
            square([len, width], center=true);

        // Slot 2
        rotate([0,0,90])
            linear_extrude(height=depth + eps, scale=1 + taper, convexity=5)
                square([len, width], center=true);
    }
}

module screw() {
    difference() {
        union() {
            // Shaft with threads
            threaded_shaft(shaft_diameter, shaft_length, pitch, thread_depth);

            // Dome head connected at shaft end (base plane at z=shaft_length)
            translate([0,0,shaft_length])
                dome_head_cap(head_diameter, head_height);
        }

        // Drive recess in head (cuts into the cap)
        translate([0,0,shaft_length])
            phillips_recess(drive_depth, drive_width, drive_len, drive_taper);
    }
}

screw();