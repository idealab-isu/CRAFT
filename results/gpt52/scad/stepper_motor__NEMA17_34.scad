$fn=96;

face_w = 42.3;
body_len = 34.0;

shaft_d = 5.0;
shaft_len = 22.0;

mount_spacing = 31.0;
mount_hole_d = 3.2;

front_boss_d = 22.0;
front_boss_h = 2.0;

corner_r = 4.0;

module rounded_box_xy(w, h, r, center=true){
    ww = w - 2*r;
    hh = h - 2*r;
    if (ww < 0) ww = 0;
    if (hh < 0) hh = 0;

    translate(center ? [-w/2, -h/2, 0] : [0,0,0])
    minkowski(){
        cube([ww, hh, 0.01], center=false);
        cylinder(r=r, h=0.01, center=false);
    }
}

module motor_body(){
    difference(){
        linear_extrude(height=body_len, center=true, convexity=10)
            rounded_box_xy(face_w, face_w, corner_r, center=true);

        for (sx = [-1, 1], sy = [-1, 1]){
            translate([sx*mount_spacing/2, sy*mount_spacing/2, 0])
                cylinder(d=mount_hole_d, h=body_len+2, center=true);
        }
    }
}

module front_features(){
    translate([0,0, body_len/2])
        cylinder(d=front_boss_d, h=front_boss_h, center=false);

    translate([0,0, body_len/2 + front_boss_h])
        cylinder(d=shaft_d, h=shaft_len, center=false);
}

union(){
    motor_body();
    front_features();
}