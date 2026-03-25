$fn=96;

face_w = 56.4;
body_len = 51.2;

shaft_d = 6.35;
shaft_len = 20;

mount_spacing = 47.1;
mount_hole_d = 4.2;
mount_hole_depth = 6;

front_boss_d = 22;
front_boss_h = 2;

corner_r = 3;

module rounded_box_xy(size=[10,10,10], r=1, center=true){
    x=size[0]; y=size[1]; z=size[2];
    translate(center ? [-x/2,-y/2,-z/2] : [0,0,0])
        linear_extrude(height=z)
            offset(r=r)
                square([x-2*r, y-2*r], center=false);
}

module motor_body(){
    difference(){
        rounded_box_xy([face_w, face_w, body_len], r=corner_r, center=true);
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*mount_spacing/2, sy*mount_spacing/2, body_len/2 - mount_hole_depth])
                cylinder(d=mount_hole_d, h=mount_hole_depth+0.2, center=false);
        }
    }
}

module front_features(){
    translate([0,0,body_len/2])
        cylinder(d=front_boss_d, h=front_boss_h, center=false);
    translate([0,0,body_len/2 + front_boss_h])
        cylinder(d=shaft_d, h=shaft_len, center=false);
}

union(){
    motor_body();
    front_features();
}