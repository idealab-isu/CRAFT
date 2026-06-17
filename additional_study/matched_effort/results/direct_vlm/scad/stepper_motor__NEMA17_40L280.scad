$fn = 96;

// Requested critical dimensions (mm)
face_w        = 42.3;   // square face width
body_len      = 40.0;   // motor body length (front face to rear face)
shaft_d       = 8.0;    // shaft diameter
shaft_len     = 22.0;   // shaft protrusion from front face
mount_spacing = 31.0;   // mounting hole center-to-center spacing

// Typical NEMA17-like details (kept reasonable, not critical)
mount_hole_d   = 3.5;   // clearance
front_boss_d   = 22.0;  // pilot/boss diameter
front_boss_h   = 2.0;   // pilot/boss height (protrudes from front face)
corner_r       = 3.0;   // corner radius
rear_boss_d    = 16.0;  // rear bearing/seat hint
rear_boss_h    = 1.5;   // rear boss height (protrudes from rear face)
connector_w    = 14.0;  // rear connector block width
connector_h    = 8.0;   // rear connector block height
connector_len  = 6.0;   // rear connector block protrusion
wire_d         = 2.2;   // wire diameter
wire_len       = 18.0;  // wire protrusion
overlap        = 0.4;   // small overlap to ensure watertight unions

module rounded_square_2d(w, r) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r), sy*(w/2 - r)])
                circle(r=r);
    }
}

module rounded_square_prism(w, h, r, center=false) {
    linear_extrude(height=h, center=center)
        rounded_square_2d(w, r);
}

module stepper_motor() {
    // Coordinate system:
    // - Z is motor axis
    // - Front face at z=0
    // - Body extends to z=body_len
    // - Shaft extends to negative Z

    difference() {
        union() {
            // Main body (single connected solid)
            rounded_square_prism(face_w, body_len, corner_r, center=false);

            // Front boss/pilot (protrudes from front face)
            translate([0, 0, -front_boss_h + overlap])
                cylinder(d=front_boss_d, h=front_boss_h + overlap, center=false);

            // Shaft (connected to boss/front face)
            translate([0, 0, -shaft_len - front_boss_h + overlap])
                cylinder(d=shaft_d, h=shaft_len + front_boss_h + overlap, center=false);

            // Rear boss/seat hint (protrudes from rear face)
            translate([0, 0, body_len - overlap])
                cylinder(d=rear_boss_d, h=rear_boss_h + overlap, center=false);

            // Rear connector block (attached to rear face, offset to one side)
            translate([face_w/2 - connector_w/2 - corner_r, 0, body_len - overlap])
                cube([connector_w, connector_h, connector_len + overlap], center=true);

            // Wires exiting connector (two wires)
            for (wy = [-wire_d*1.2, wire_d*1.2]) {
                translate([face_w/2 - connector_w/2 - corner_r + connector_w/2, wy, body_len + connector_len - overlap])
                    rotate([0, 90, 0])
                        cylinder(d=wire_d, h=wire_len + overlap, center=false);
            }
        }

        // Mounting holes through the body (along Z)
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x, y, -shaft_len - front_boss_h - 1])
                    cylinder(d=mount_hole_d, h=body_len + shaft_len + front_boss_h + rear_boss_h + connector_len + 2, center=false);
    }
}

stepper_motor();