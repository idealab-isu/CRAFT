$fn = 96;

// Parameters
face_w = 20.0;          // motor face width (square)
body_len = 30.0;        // motor body length
shaft_d = 4.0;          // shaft diameter
mount_spacing = 16.0;   // mounting hole spacing (center-to-center)
mount_hole_d = 3.0;     // typical small stepper mounting hole
face_plate_th = 2.0;    // front face plate thickness
boss_d = 10.0;          // front boss diameter
boss_h = 1.5;           // front boss height
shaft_len = 15.0;       // shaft protrusion length
corner_r = 1.2;         // slight rounding on body edges

module rounded_box_xy(w, h, r, z) {
    // Rounded rectangle extruded in Z
    linear_extrude(height = z)
        offset(r = r)
            square([w - 2*r, h - 2*r], center = true);
}

module stepper_motor() {
    difference() {
        union() {
            // Main body
            translate([0,0,0])
                rounded_box_xy(face_w, face_w, corner_r, body_len);

            // Front face plate (slightly proud)
            translate([0,0,body_len])
                rounded_box_xy(face_w, face_w, corner_r, face_plate_th);

            // Front boss
            translate([0,0,body_len + face_plate_th])
                cylinder(d = boss_d, h = boss_h);

            // Shaft
            translate([0,0,body_len + face_plate_th + boss_h])
                cylinder(d = shaft_d, h = shaft_len);
        }

        // Mounting holes through face plate and a bit into body
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x, y, body_len - 1])
                    cylinder(d = mount_hole_d, h = face_plate_th + boss_h + 2);
    }
}

stepper_motor();