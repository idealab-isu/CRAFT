$fn=96;

face_w = 35.2;
body_len = 36.0;

shaft_d = 5.0;
shaft_len = 20.0;

hole_spacing = 26.0;
hole_d = 3.2;
hole_depth = 6.0;

front_boss_d = 22.0;
front_boss_h = 2.0;

corner_r = 3.0;

module rounded_square_prism(w, h, r, center=true){
    linear_extrude(height=h, center=center)
        offset(r=r)
            offset(delta=-r)
                square([w, w], center=true);
}

module motor_body(){
    difference(){
        rounded_square_prism(face_w, body_len, corner_r, center=true);
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*hole_spacing/2, sy*hole_spacing/2, body_len/2 - hole_depth])
                cylinder(d=hole_d, h=hole_depth+0.2, center=false);
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