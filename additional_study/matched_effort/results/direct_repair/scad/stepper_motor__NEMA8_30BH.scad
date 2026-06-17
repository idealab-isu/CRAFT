$fn = 96;

face_w = 20.0;          // square face width
body_len = 30.0;        // motor body length (excluding shaft)
shaft_d = 5.0;          // shaft diameter
shaft_len = 18.0;       // visible shaft length
mount_spacing = 16.0;   // center-to-center spacing of mounting holes
mount_hole_d = 3.0;     // typical small stepper mounting hole
front_plate_th = 2.0;   // front face plate thickness
boss_d = 12.0;          // front boss diameter
boss_h = 2.0;           // front boss height
corner_r = 1.2;         // slight edge rounding approximation

module rounded_box_xy(w, h, r, z) {
    // 2D rounded rectangle extruded
    linear_extrude(height = z)
        offset(r = r)
            square([w - 2*r, h - 2*r], center = true);
}

module stepper_motor() {
    // Body centered on origin, front face at +Z
    union() {
        // Main body
        translate([0,0,-body_len])
            rounded_box_xy(face_w, face_w, corner_r, body_len);

        // Front plate
        rounded_box_xy(face_w, face_w, corner_r, front_plate_th);

        // Front boss
        cylinder(d = boss_d, h = boss_h);

        // Shaft
        translate([0,0,boss_h])
            cylinder(d = shaft_d, h = shaft_len);
    }
}

module motor_with_mount_holes() {
    difference() {
        stepper_motor();

        // Mounting holes through front plate and slightly into body
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x, y, -0.5])
                    cylinder(d = mount_hole_d, h = front_plate_th + 2.0);
    }
}

motor_with_mount_holes();