$fn = 128;

// Target dimensions (mm)
shaft_diameter  = 5.0;     // shank major diameter
head_diameter   = 10.0;    // pan head max diameter
head_height     = 3.95;    // head height
overall_length  = 10.0;    // total length (tip to top)

// Derived
shaft_length = overall_length - head_height;

// Small overlap to guarantee watertight unions/differences
eps = 0.03;

// Visual thread approximation (not ISO-accurate)
thread_pitch = 1.0;        // mm per turn
thread_depth = 0.35;       // radial depth (mm)
thread_len   = shaft_length;

// Drive recess (simple Phillips-like cross)
recess_depth = head_height * 0.55;
recess_w     = head_diameter * 0.18;
recess_l     = head_diameter * 0.75;

// Pan head profile controls (rounded dome, not conical)
head_cyl_h   = head_height * 0.45;   // straight cylindrical skirt height
dome_h       = head_height - head_cyl_h;

module thread_approx(d_major, depth, pitch, len) {
    // Shallow helical ridge around a cylinder.
    // Ridge is centered near the major radius and protrudes outward by ~depth.
    turns = len / pitch;
    linear_extrude(height = len, twist = -360 * turns, slices = max(80, ceil(turns * 60)))
        translate([d_major/2 - depth, 0, 0])
            square([depth, pitch * 0.55], center = false);
}

module pan_head_solid(d, h) {
    // Pan head: cylindrical skirt + rounded dome (spherical cap approximation)
    r = d/2;

    // Dome radius chosen so the cap height is dome_h and base radius is r:
    // R = (a^2 + h^2) / (2h)
    R = (r*r + dome_h*dome_h) / (2*dome_h);
    zc = head_cyl_h + (dome_h - R); // sphere center z so cap height is dome_h above skirt

    union() {
        // Cylindrical skirt
        cylinder(h = head_cyl_h, r = r);

        // Rounded dome (intersection of sphere with a limiting cylinder)
        intersection() {
            translate([0,0,zc]) sphere(r = R);
            translate([0,0,head_cyl_h - eps])
                cylinder(h = dome_h + 2*eps, r = r);
        }
    }
}

module drive_recess_cut() {
    // Cut from the top down into the head
    translate([0,0,overall_length - recess_depth + eps])
        union() {
            cube([recess_l, recess_w, recess_depth + 2*eps], center = true);
            cube([recess_w, recess_l, recess_depth + 2*eps], center = true);
        }
}

module screw() {
    difference() {
        union() {
            // Core shaft (minor diameter) to support thread ridge
            d_minor = shaft_diameter - 2*thread_depth;
            cylinder(h = shaft_length, d = d_minor);

            // Thread ridge (approx) - starts at z=0 and ends at z=shaft_length
            thread_approx(shaft_diameter, thread_depth, thread_pitch, thread_len);

            // Pan head connected to shaft (head base at z=shaft_length)
            translate([0,0,shaft_length - eps])
                pan_head_solid(head_diameter, head_height + eps);

            // Small tip chamfer within the shaft length (does not change overall_length)
            cylinder(h = 0.6, d1 = shaft_diameter * 0.85, d2 = shaft_diameter);
        }

        // Drive recess
        drive_recess_cut();
    }
}

screw();