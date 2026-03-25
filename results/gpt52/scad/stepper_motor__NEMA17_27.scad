$fn=96;

face_w = 42.3;
body_len = 26.5;

shaft_d = 5.0;
shaft_len = 20.0;

mount_spacing = 31.0;
mount_hole_d = 3.2;

front_plate_th = 2.0;
boss_d = 22.0;
boss_h = 2.0;

corner_r = 3.0;

module rounded_square_prism(w, h, r, zlen) {
    linear_extrude(height=zlen, center=true)
        offset(r=r)
            square([w-2*r, h-2*r], center=true);
}

module motor_body() {
    difference() {
        rounded_square_prism(face_w, face_w, corner_r, body_len);
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*mount_spacing/2, sy*mount_spacing/2, body_len/2 - front_plate_th/2])
                cylinder(d=mount_hole_d, h=front_plate_th + 0.6, center=true);
        }
    }
}

module front_features() {
    translate([0,0, body_len/2 + boss_h/2])
        cylinder(d=boss_d, h=boss_h, center=true);

    translate([0,0, body_len/2 + boss_h + shaft_len/2])
        cylinder(d=shaft_d, h=shaft_len, center=true);
}

union() {
    motor_body();
    front_features();
}