$fn=96;

face_w = 42.3;
body_len = 40.0;

shaft_d = 5.0;
shaft_len = 22.0;

mount_spacing = 31.0;
mount_hole_d = 3.2;

front_plate_th = 2.0;
boss_d = 22.0;
boss_h = 2.0;

corner_r = 3.0;

module rounded_box_xy(size=[10,10,10], r=1, center=true){
    x=size[0]; y=size[1]; z=size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
    linear_extrude(height=z, center=true)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module motor_body(){
    union(){
        rounded_box_xy([face_w, face_w, body_len], r=corner_r, center=true);
        translate([0,0, body_len/2 - front_plate_th/2])
            cube([face_w, face_w, front_plate_th], center=true);
    }
}

module front_features(){
    union(){
        translate([0,0, body_len/2 + boss_h/2])
            cylinder(d=boss_d, h=boss_h, center=true);
        translate([0,0, body_len/2 + boss_h + shaft_len/2])
            cylinder(d=shaft_d, h=shaft_len, center=true);
    }
}

module mounting_holes(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_spacing/2, sy*mount_spacing/2, body_len/2 - front_plate_th/2])
            cylinder(d=mount_hole_d, h=front_plate_th+0.6, center=true);
    }
}

difference(){
    union(){
        motor_body();
        front_features();
    }
    mounting_holes();
}