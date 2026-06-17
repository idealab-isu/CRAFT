$fn = 128;

// Target dimensions (mm)
face_w        = 42.3;   // square face width (X,Y)
body_len      = 47.0;   // body length (Z, from front face to back face)
shaft_d       = 5.0;    // shaft diameter
shaft_len     = 22.0;   // shaft protrusion length (in front of front face)
mount_spacing = 31.0;   // mounting hole center-to-center (X and Y)
mount_hole_d  = 3.2;    // clearance for M3

// Typical NEMA17-like details (kept modest, but connected and verifiable)
corner_r      = 3.0;    // body corner radius
front_plate_t = 3.0;    // front face plate thickness (included within body length)
front_boss_d  = 22.0;   // pilot/boss diameter
front_boss_h  = 2.0;    // pilot/boss height (in front of front face)

// Small overlap to guarantee one connected solid
overlap = 0.4;

// Helpers
module rounded_square_2d(w, r) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module rounded_square_prism(w, h, r, center=false) {
    linear_extrude(height=h, center=center) rounded_square_2d(w, r);
}

module stepper_motor() {
    // Coordinate system:
    // Front face at z=0, body extends to +Z (0..body_len), shaft/boss extend to -Z.
    difference() {
        union() {
            // Main body: exactly 0 .. body_len
            translate([0, 0, body_len/2])
                rounded_square_prism(face_w, body_len, corner_r, center=true);

            // Front plate: sits on the front face (0..front_plate_t), overlaps into body
            translate([0, 0, front_plate_t/2 - overlap/2])
                rounded_square_prism(face_w, front_plate_t + overlap, corner_r, center=true);

            // Front boss/pilot: protrudes out of front, overlaps into plate
            translate([0, 0, -front_boss_h/2 + overlap/2])
                cylinder(d=front_boss_d, h=front_boss_h + overlap, center=true);

            // Shaft: protrudes out of front, overlaps into boss
            translate([0, 0, -(front_boss_h + shaft_len/2) + overlap/2])
                cylinder(d=shaft_d, h=shaft_len + overlap, center=true);
        }

        // Mounting holes: through the full body (and plate region), centered on the 31mm square pattern
        // Start slightly in front of z=0 and extend past z=body_len to guarantee a clean cut.
        for (x = [-mount_spacing/2, mount_spacing/2],
             y = [-mount_spacing/2, mount_spacing/2]) {
            translate([x, y, body_len/2])
                cylinder(d=mount_hole_d, h=body_len + 2, center=true);
        }
    }
}

stepper_motor();