$fn = 96;

// Parameters (mm)
face_w = 20.0;          // square face width
body_len = 30.0;        // body length (along Z)
shaft_d = 5.0;          // shaft diameter
shaft_len = 18.0;       // visible shaft length
mount_spacing = 16.0;   // center-to-center spacing of mounting holes
mount_hole_d = 3.2;     // typical M3 clearance
face_th = 2.0;          // front face plate thickness
pilot_d = 12.0;         // front pilot boss diameter
pilot_h = 1.5;          // pilot boss height
corner_r = 1.2;         // body corner radius

module rounded_box_xy(w, h, r, zlen) {
    // Rounded rectangle extruded along Z
    linear_extrude(height = zlen)
        offset(r = r)
            square([w - 2*r, h - 2*r], center = true);
}

module stepper_motor() {
    difference() {
        union() {
            // Main body
            color([0.25,0.25,0.25])
                rounded_box_xy(face_w, face_w, corner_r, body_len);

            // Front face plate
            color([0.35,0.35,0.35])
                translate([0,0,body_len - face_th])
                    rounded_box_xy(face_w, face_w, corner_r, face_th);

            // Front pilot boss
            color([0.55,0.55,0.55])
                translate([0,0,body_len])
                    cylinder(d = pilot_d, h = pilot_h);

            // Shaft
            color([0.75,0.75,0.75])
                translate([0,0,body_len + pilot_h])
                    cylinder(d = shaft_d, h = shaft_len);

            // Rear cap (slight)
            color([0.2,0.2,0.2])
                translate([0,0,-1.0])
                    rounded_box_xy(face_w, face_w, corner_r, 1.0);
        }

        // Mounting holes through front face plate (and slightly into body)
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x,y,body_len - face_th - 0.5])
                    cylinder(d = mount_hole_d, h = face_th + 1.5);

        // Optional center clearance in face (around pilot) - shallow
        translate([0,0,body_len - face_th - 0.01])
            cylinder(d = pilot_d + 0.6, h = face_th + 0.02);
    }
}

stepper_motor();