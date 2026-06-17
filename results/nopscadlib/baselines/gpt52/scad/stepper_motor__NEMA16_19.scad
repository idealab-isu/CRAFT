$fn=96;

face_w = 39.5;
body_len = 19.2;

shaft_d = 5.0;
shaft_len = 20.0;

mount_spacing = 31.0;
mount_hole_d = 3.2;

front_boss_d = 22.0;
front_boss_h = 2.0;

corner_r = 3.0;

module rounded_square_prism(w, h, r, zlen) {
    linear_extrude(height=zlen, center=true)
        offset(r=r)
            square([w-2*r, h-2*r], center=true);
}

module motor_body() {
    rounded_square_prism(face_w, face_w, corner_r, body_len);
}

module mount_holes(zlen) {
    for (sx=[-1,1], sy=[-1,1]) {
        translate([sx*mount_spacing/2, sy*mount_spacing/2, 0])
            cylinder(d=mount_hole_d, h=zlen+2, center=true);
    }
}

module front_boss() {
    translate([0,0, body_len/2 + front_boss_h/2])
        cylinder(d=front_boss_d, h=front_boss_h, center=true);
}

module shaft() {
    translate([0,0, body_len/2 + front_boss_h + shaft_len/2])
        cylinder(d=shaft_d, h=shaft_len, center=true);
}

module stepper_motor() {
    union() {
        difference() {
            motor_body();
            mount_holes(body_len);
        }
        front_boss();
        shaft();
    }
}

stepper_motor();