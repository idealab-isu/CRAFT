$fn = 96;

// Target dimensions (mm)
face_w = 56.4;          // motor face width (square)
body_len = 51.2;        // motor body length (along Z, behind face)
shaft_d = 6.35;         // shaft diameter
shaft_len = 20;         // shaft protrusion from front face
mount_spacing = 47.1;   // mounting hole center-to-center spacing (square pattern)

// Typical details (reasonable defaults)
front_plate_t = 3.0;    // front face thickness
pilot_d = 38.0;         // front pilot/boss diameter
pilot_h = 2.0;          // pilot height
hole_d = 3.5;           // mounting hole diameter (visual only; not cut through)
hole_boss_d = 6.0;      // visible ring/boss around each mounting hole
hole_boss_h = 0.8;      // height of ring/boss above face
corner_r = 3.0;         // slight corner rounding
overlap = 0.25;         // small overlap to ensure watertight unions

// Rounded square prism (centered in X/Y, Z from 0..h)
module rounded_square_prism(w, h, r) {
    linear_extrude(height = h)
        offset(r = r)
            square([w - 2*r, w - 2*r], center = true);
}

// A visible "mounting hole" feature that remains a single solid:
// a short ring (washer-like boss) on the face.
module hole_ring(d_outer, d_inner, h) {
    difference() {
        cylinder(h = h, d = d_outer, center = false);
        translate([0, 0, -overlap])
            cylinder(h = h + 2*overlap, d = d_inner, center = false);
    }
}

module stepper_motor() {
    union() {
        // Main body behind the face: Z from -body_len .. 0
        translate([0, 0, -body_len])
            rounded_square_prism(face_w, body_len, corner_r);

        // Front face plate: Z from 0 .. front_plate_t
        rounded_square_prism(face_w, front_plate_t, corner_r);

        // Front pilot/boss: connected to face
        translate([0, 0, front_plate_t - overlap])
            cylinder(h = pilot_h + overlap, d = pilot_d, center = false);

        // Shaft: connected to pilot
        translate([0, 0, front_plate_t + pilot_h - overlap])
            cylinder(h = shaft_len + overlap, d = shaft_d, center = false);

        // Visible mounting hole rings on the front face at the specified spacing
        // Z from front_plate_t - overlap .. front_plate_t + hole_boss_h
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * mount_spacing/2, sy * mount_spacing/2, front_plate_t - overlap])
                    hole_ring(hole_boss_d, hole_d, hole_boss_h + overlap);
    }
}

stepper_motor();