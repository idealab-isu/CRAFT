$fn = 96;

// Parameters (mm)
face_w = 42.3;          // motor face width (square)
body_len = 47.0;        // motor body length (excluding front boss/shaft)
shaft_d = 5.0;          // shaft diameter
mount_spacing = 31.0;   // mounting hole center-to-center spacing (square pattern)

// Typical NEMA17-ish details (not provided; chosen as reasonable defaults)
corner_r = 3.0;         // body corner radius
front_boss_d = 22.0;    // front pilot/boss diameter
front_boss_h = 2.0;     // front pilot/boss height
mount_hole_d = 3.2;     // clearance for M3
shaft_len = 24.0;       // shaft protrusion length from front face
shaft_flat = 0.0;       // set >0 to add a flat (e.g., 0.5)

// Helpers
module rounded_square_prism(w, h, r, center=false) {
    linear_extrude(height=h, center=center)
        offset(r=r)
            square([w-2*r, w-2*r], center=true);
}

module shaft_with_optional_flat(d, h, flat=0) {
    if (flat <= 0) {
        cylinder(d=d, h=h);
    } else {
        // D-shaft: subtract a slab to create a flat
        difference() {
            cylinder(d=d, h=h);
            translate([d/2 - flat, 0, -0.5])
                cube([d, d*2, h+1], center=true);
        }
    }
}

module stepper_motor() {
    difference() {
        // Main body
        translate([0,0,0])
            rounded_square_prism(face_w, body_len, corner_r, center=false);

        // Mounting holes through body (from front face)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*mount_spacing/2, sy*mount_spacing/2, -0.5])
                cylinder(d=mount_hole_d, h=body_len+1);
        }
    }

    // Front boss (pilot)
    translate([0,0,body_len])
        cylinder(d=front_boss_d, h=front_boss_h);

    // Shaft
    translate([0,0,body_len + front_boss_h])
        shaft_with_optional_flat(shaft_d, shaft_len, shaft_flat);
}

stepper_motor();