$fn = 96;

// Requested dimensions
face_w       = 20.0;   // square face width (X,Y)
body_len     = 30.0;   // body length (Z)
shaft_d      = 5.0;    // shaft diameter
shaft_len    = 12.0;   // shaft protrusion from front face
hole_spacing = 16.0;   // mounting hole spacing (center-to-center)
hole_d       = 3.0;    // mounting hole diameter (through-holes)

// Visual/typical stepper features (kept small so requested dims remain verifiable)
front_plate_t = 2.0;   // front face thickness
boss_d        = 10.0;  // front boss diameter
boss_h        = 2.0;   // front boss height

// Small overlap to guarantee connectivity in unions/differences
overlap = 0.2;

module stepper_motor() {
    // Coordinate system:
    // Front face plane at z = 0
    // Body extends to negative Z
    // Shaft extends to positive Z
    difference() {
        union() {
            // Main body: exact 20x20 face, exact 30mm length
            translate([0, 0, -body_len/2])
                cube([face_w, face_w, body_len], center=true);

            // Front plate: attached to body, extends slightly forward
            translate([0, 0, -front_plate_t/2 + overlap/2])
                cube([face_w, face_w, front_plate_t + overlap], center=true);

            // Front boss: attached to front plate
            translate([0, 0, boss_h/2 - overlap/2])
                cylinder(h=boss_h + overlap, d=boss_d, center=true);

            // Shaft: attached to boss, protrudes forward by shaft_len from z=0
            // Base starts slightly inside boss for connectivity.
            translate([0, 0, shaft_len/2 - overlap/2])
                cylinder(h=shaft_len + overlap, d=shaft_d, center=true);
        }

        // Through mounting holes: cut through front plate and slightly into body
        hole_cut_h = front_plate_t + 2*overlap + 2.0; // ensures visible through-holes
        hole_cut_z = -(front_plate_t/2) - 1.0;        // centered so it cuts plate and a bit of body
        for (x = [-1, 1])
            for (y = [-1, 1])
                translate([x*hole_spacing/2, y*hole_spacing/2, hole_cut_z])
                    cylinder(h=hole_cut_h, d=hole_d, center=true);
    }
}

stepper_motor();