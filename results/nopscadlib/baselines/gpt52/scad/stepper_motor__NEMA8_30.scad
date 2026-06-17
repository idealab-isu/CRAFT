$fn=64;

face_w = 20.0;
body_len = 30.0;
shaft_d = 4.0;
shaft_len = 12.0;

mount_spacing = 16.0;
mount_hole_d = 3.2;

corner_r = 2.0;
front_plate_t = 2.0;

boss_d = 10.0;
boss_h = 2.0;

module rounded_box(size=[20,20,30], r=2) {
    x = size[0]; y = size[1]; z = size[2];
    hull() {
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*(x/2 - r), sy*(y/2 - r), -z/2])
                cylinder(h=z, r=r);
        }
    }
}

module motor_body() {
    union() {
        rounded_box([face_w, face_w, body_len], corner_r);
        translate([0,0, body_len/2 - front_plate_t/2])
            cube([face_w, face_w, front_plate_t], center=true);
    }
}

module mounting_holes() {
    for (sx=[-1,1], sy=[-1,1]) {
        translate([sx*mount_spacing/2, sy*mount_spacing/2, body_len/2 - front_plate_t - 0.1])
            cylinder(h=front_plate_t + 0.2, d=mount_hole_d);
    }
}

module front_features() {
    union() {
        translate([0,0, body_len/2])
            cylinder(h=boss_h, d=boss_d);
        translate([0,0, body_len/2 + boss_h])
            cylinder(h=shaft_len, d=shaft_d);
    }
}

module stepper_motor() {
    union() {
        difference() {
            motor_body();
            mounting_holes();
        }
        front_features();
    }
}

stepper_motor();