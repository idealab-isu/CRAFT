$fn = 96;

// Target dimensions (mm)
face_w = 42.3;                 // square face width
body_len = 40.0;               // motor body length (front face to back face)
shaft_d = 8.0;                 // output shaft diameter
mount_spacing = 31.0;          // mounting hole center-to-center spacing

// Typical NEMA17-like details (kept reasonable, not part of the 4 critical dims)
corner_r = 2.0;                // body corner radius
front_plate_t = 2.0;           // front face plate thickness
boss_d = 22.0;                 // front boss diameter
boss_h = 2.0;                  // front boss height
mount_hole_d = 3.5;            // mounting hole diameter
mount_counterbore_d = 6.5;     // shallow counterbore to make holes visible
mount_counterbore_t = 0.8;     // counterbore depth
shaft_len = 20.0;              // shaft protrusion from boss front
back_boss_d = 18.0;            // rear bearing boss diameter
back_boss_h = 1.5;             // rear boss height
connector_w = 16.0;            // rear connector block width
connector_h = 10.0;            // rear connector block height
connector_len = 8.0;           // rear connector block length (protrusion)
cable_d = 5.0;                 // cable bundle diameter
cable_len = 18.0;              // cable protrusion length

eps = 0.25;                    // overlap to guarantee connectivity

// Rounded-rectangle prism (Z axis length)
module rounded_box_xy(w, h, z, r) {
    linear_extrude(height = z, center = true)
        offset(r = r)
            square([w - 2*r, h - 2*r], center = true);
}

module motor_body() {
    rounded_box_xy(face_w, face_w, body_len, corner_r);
}

module front_face_with_holes() {
    // Plate + boss, with mounting holes (holes are subtracted later from whole motor)
    union() {
        // front plate sits flush on body front face, overlaps slightly into body
        translate([0, 0, body_len/2 - front_plate_t/2 + eps/2])
            cube([face_w, face_w, front_plate_t + eps], center = true);

        // boss protrudes forward from plate, overlaps slightly into plate
        translate([0, 0, body_len/2 + boss_h/2 - eps/2])
            cylinder(h = boss_h + eps, d = boss_d, center = true);
    }
}

module output_shaft() {
    // Shaft starts at boss front face and extends forward only
    translate([0, 0, body_len/2 + boss_h + shaft_len/2 - eps/2])
        cylinder(h = shaft_len + eps, d = shaft_d, center = true);
}

module back_features() {
    union() {
        // rear bearing boss
        translate([0, 0, -body_len/2 - back_boss_h/2 + eps/2])
            cylinder(h = back_boss_h + eps, d = back_boss_d, center = true);

        // connector block on rear face (offset slightly down), overlaps into body
        translate([0, -face_w*0.18, -body_len/2 - connector_len/2 + eps/2])
            cube([connector_w, connector_h, connector_len + eps], center = true);

        // cable bundle exiting connector
        translate([0, -face_w*0.18, -body_len/2 - connector_len - cable_len/2 + eps/2])
            cylinder(h = cable_len + eps, d = cable_d, center = true);
    }
}

module mounting_holes() {
    // Through the front plate only (plus a shallow counterbore) so they are visible in front view
    for (x = [-1, 1], y = [-1, 1]) {
        // Through-hole
        translate([x * mount_spacing/2, y * mount_spacing/2, body_len/2 - front_plate_t/2])
            cylinder(h = front_plate_t + 4*eps, d = mount_hole_d, center = true);

        // Counterbore (shallow, on the very front)
        translate([x * mount_spacing/2, y * mount_spacing/2,
                   body_len/2 + mount_counterbore_t/2 - eps/2])
            cylinder(h = mount_counterbore_t + 2*eps, d = mount_counterbore_d, center = true);
    }
}

module stepper_motor() {
    // ONE connected solid, with holes subtracted from the assembled motor
    difference() {
        union() {
            motor_body();
            front_face_with_holes();
            output_shaft();
            back_features();
        }
        mounting_holes();
    }
}

stepper_motor();