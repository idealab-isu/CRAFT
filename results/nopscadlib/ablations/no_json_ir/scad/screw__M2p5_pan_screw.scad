// Metric Pan Head Screw — 2.5mm shank dia, 4.7mm head dia, 1.7mm head height, 10mm long
// One connected solid with simple helical thread approximation.

$fn = 128;

// Parameters (mm)
shank_diameter = 2.5;
shank_length   = 10;

head_diameter  = 4.7;
head_height    = 1.7;

// Pan head profile (more typical: cylindrical skirt + domed crown)
head_crown_h   = 0.75;                       // domed top portion height
head_side_h    = max(0.01, head_height - head_crown_h);
head_top_d     = head_diameter * 0.86;       // taper toward top

// Drive recess (simple Phillips-like cross)
recess_depth   = 0.55;
recess_w       = 0.55;
recess_len     = head_diameter * 0.78;

// Thread (visual approximation)
thread_pitch   = 0.5;
thread_depth   = 0.18;  // radial height of thread ridge
thread_start_z = 0.2;
thread_end_z   = shank_length - 0.2;

// Small overlap to guarantee watertight unions
overlap = 0.08;

module pan_head_solid() {
    // Cylindrical skirt + domed crown (no flange)
    union() {
        // Skirt (slight taper)
        cylinder(h = head_side_h, d1 = head_diameter, d2 = head_top_d);

        // Domed crown: intersection of a sphere with a limiting cylinder
        translate([0, 0, head_side_h - overlap])
            intersection() {
                cylinder(h = head_crown_h + 2*overlap, d = head_diameter);
                // Sphere sized so its equator is near the skirt top, giving a pan-head dome
                translate([0, 0, head_crown_h])
                    sphere(d = head_diameter);
            }
    }
}

module drive_recess_cut() {
    // Cross recess cut into top of head
    translate([0, 0, head_height - recess_depth])
        union() {
            cube([recess_len, recess_w, recess_depth + 2*overlap], center = true);
            cube([recess_w, recess_len, recess_depth + 2*overlap], center = true);
        }
}

module shank_solid() {
    cylinder(h = shank_length, d = shank_diameter);
}

module helical_thread_ridge() {
    // Helical ridge around shank (unioned to shank to remain one solid)
    turns = (thread_end_z - thread_start_z) / thread_pitch;
    steps_per_turn = 28;
    steps = max(12, ceil(turns * steps_per_turn));
    dz = (thread_end_z - thread_start_z) / steps;
    dtheta = 360 * turns / steps;

    // Place ridge so it protrudes outward from the shank surface
    r = shank_diameter/2 + thread_depth/2 - overlap;

    for (i = [0 : steps-1]) {
        z0 = thread_start_z + i*dz;
        z1 = z0 + dz + overlap;
        theta0 = i*dtheta;
        theta1 = theta0 + dtheta;

        hull() {
            rotate([0, 0, theta0])
                translate([r, 0, z0])
                    cylinder(h = overlap, d = thread_depth, $fn = 24);

            rotate([0, 0, theta1])
                translate([r, 0, z1])
                    cylinder(h = overlap, d = thread_depth, $fn = 24);
        }
    }
}

module screw() {
    // Shank from z=0..shank_length, head from z=shank_length..shank_length+head_height
    difference() {
        union() {
            shank_solid();

            // Thread ridge overlaps shank slightly (same z-range)
            helical_thread_ridge();

            // Head connected to shank with calculated overlap
            translate([0, 0, shank_length - overlap])
                pan_head_solid();
        }

        // Recess cut from head top (aligned to head placement)
        translate([0, 0, shank_length - overlap])
            drive_recess_cut();
    }
}

screw();