$fn = 96;

// Requested dimensions
face_width     = 42.3;   // mm (square face)
body_length    = 26.5;   // mm (motor body length)
shaft_diameter = 5.0;    // mm
hole_spacing   = 31.0;   // mm (center-to-center)

// Reasonable NEMA17-like details (kept simple but recognizable)
front_plate_th = 2.0;    // mm
rear_plate_th  = 2.0;    // mm
boss_diameter  = 22.0;   // mm (typical pilot/boss)
boss_height    = 2.0;    // mm
shaft_length   = 20.0;   // mm
hole_diameter  = 3.5;    // mm (clearance)
corner_cut     = 4.0;    // mm (chamfer-ish corner relief)
overlap        = 0.2;    // mm (ensures watertight unions)

module chamfered_block_xy(w, h, zlen, cut) {
    // Creates a block with 45° corner cuts in XY using hull of 4 corner posts
    hull() {
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(w/2 - cut), sy*(h/2 - cut), 0])
                cube([2*cut, 2*cut, zlen], center=true);
        }
    }
}

module stepper_motor() {
    // Coordinate system:
    // Front face at z=0, body extends to negative z, shaft extends to positive z.
    difference() {
        union() {
            // Main body (slightly chamfered corners for recognizability)
            translate([0, 0, -body_length/2])
                chamfered_block_xy(face_width, face_width, body_length, corner_cut);

            // Front plate (flush with front face, overlaps into body)
            translate([0, 0, -front_plate_th/2 + overlap/2])
                cube([face_width, face_width, front_plate_th + overlap], center=true);

            // Rear plate (flush with rear end, overlaps into body)
            translate([0, 0, -body_length + rear_plate_th/2 - overlap/2])
                cube([face_width, face_width, rear_plate_th + overlap], center=true);

            // Boss / pilot on front face (connected with slight overlap)
            translate([0, 0, boss_height/2 - overlap/2])
                cylinder(h=boss_height + overlap, d=boss_diameter, center=true);

            // Shaft (connected into boss with overlap)
            translate([0, 0, shaft_length/2 + boss_height - overlap])
                cylinder(h=shaft_length + 2*overlap, d=shaft_diameter, center=true);
        }

        // Mounting holes: subtract through front plate and slightly into body
        for (x = [-hole_spacing/2, hole_spacing/2])
            for (y = [-hole_spacing/2, hole_spacing/2])
                translate([x, y, -front_plate_th/2])
                    cylinder(h=front_plate_th + 4.0, d=hole_diameter, center=true);
    }
}

stepper_motor();