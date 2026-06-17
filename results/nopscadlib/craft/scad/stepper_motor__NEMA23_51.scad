$fn = 96;

// -------------------- Critical dimensions (as requested) --------------------
face_width            = 56.4;   // square face width (X,Y)
body_length           = 51.2;   // motor body length (Z)
shaft_diameter        = 6.35;   // output shaft diameter
mounting_hole_spacing = 47.1;   // 4-hole square pattern spacing (center-to-center)

// -------------------- Secondary/visual parameters --------------------------
front_plate_thickness   = 3.0;   // front flange thickness (adds to overall length)
mounting_hole_diameter  = 3.5;
mount_hole_depth        = 8.0;   // how far holes extend into body behind front plate

corner_radius           = 2.0;

front_boss_diameter     = 22.0;  // pilot/bearing boss
front_boss_height       = 2.0;

shaft_length            = 20.0;
shaft_flat              = 0;     // 0/1
shaft_flat_depth        = 0.8;
shaft_flat_length       = 14.0;

rear_boss_diameter      = 18.0;  // visual only
rear_boss_height        = 1.5;   // visual only

// Body shaping (visual only; does not change face_width or body_length)
can_diameter            = 53.0;  // cylindrical mid-body
can_length              = body_length * 0.78; // keep ends square so orthographic views differ
can_z_offset            = 0.0;

// Front face details (visual only)
face_recess_diameter    = 16.0;
face_recess_depth       = 0.8;

// Small epsilon/overlap to guarantee connectivity
overlap = 0.6;

// -------------------- Helpers --------------------
module rounded_square_2d(w, r) {
    // Robust rounded square (2D), centered
    offset(r=r)
        square([w - 2*r, w - 2*r], center=true);
}

module rounded_square_prism(w, h, r) {
    linear_extrude(height=h, center=true)
        rounded_square_2d(w, r);
}

module shaft_with_optional_flat(d, h) {
    if (shaft_flat == 1) {
        difference() {
            cylinder(d=d, h=h, center=true);
            // Flat cut along +X side
            translate([d/2 - shaft_flat_depth/2, 0, -h/2 + shaft_flat_length/2])
                cube([d, d*2, shaft_flat_length], center=true);
        }
    } else {
        cylinder(d=d, h=h, center=true);
    }
}

// -------------------- Main motor (ONE connected solid) --------------------
module stepper_motor() {

    // Coordinate convention:
    // Motor body spans Z = [-body_length/2, +body_length/2]
    // Front face is at Z = +body_length/2
    // Shaft extends in +Z

    difference() {
        union() {
            // Main square body (critical: face_width and body_length)
            rounded_square_prism(face_width, body_length, corner_radius);

            // Cylindrical mid-body "can" to read as a stepper motor (kept shorter than body)
            translate([0, 0, can_z_offset])
                cylinder(d=can_diameter, h=can_length, center=true);

            // Front plate/flange (adds detail; connected with overlap)
            translate([0, 0, body_length/2 + front_plate_thickness/2 - overlap])
                rounded_square_prism(face_width, front_plate_thickness, corner_radius);

            // Front boss/pilot (bearing boss)
            translate([0, 0, body_length/2 + front_plate_thickness + front_boss_height/2 - overlap])
                cylinder(d=front_boss_diameter, h=front_boss_height, center=true);

            // Rear boss (subtle)
            translate([0, 0, -body_length/2 - rear_boss_height/2 + overlap])
                cylinder(d=rear_boss_diameter, h=rear_boss_height, center=true);

            // Output shaft (connected to front boss)
            translate([0, 0,
                body_length/2 + front_plate_thickness + front_boss_height + shaft_length/2 - overlap])
                shaft_with_optional_flat(shaft_diameter, shaft_length);
        }

        // Mounting holes: 4-hole square pattern, spacing = mounting_hole_spacing
        // Cut through front plate and into body (but not through entire motor).
        for (x = [-1, 1], y = [-1, 1]) {
            translate([x*mounting_hole_spacing/2,
                       y*mounting_hole_spacing/2,
                       body_length/2 + front_plate_thickness/2 - overlap])
                cylinder(d=mounting_hole_diameter,
                         h=front_plate_thickness + mount_hole_depth,
                         center=true);
        }

        // Front face recess ring around shaft/boss (visual cue)
        // Cut only into the front plate (not into the boss), so it reads in front view.
        translate([0, 0, body_length/2 + front_plate_thickness/2 - overlap])
            cylinder(d=face_recess_diameter,
                     h=face_recess_depth + overlap,
                     center=true);
    }
}

stepper_motor();