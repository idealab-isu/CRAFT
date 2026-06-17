$fn=96;

face_w = 42.3;
body_len = 47.0;

shaft_d = 5.0;
shaft_len = 22.0;

mount_spacing = 31.0;
mount_hole_d = 3.2;

front_flange_th = 2.0;
rear_cap_th = 1.5;

corner_r = 3.0;

pilot_d = 22.0;
pilot_h = 2.0;

module rounded_box_xy(size=[10,10,10], r=1, center=true){
    sx = size[0];
    sy = size[1];
    sz = size[2];
    translate([0,0, center ? -sz/2 : 0])
    linear_extrude(height=sz)
        offset(r=r)
            square([sx-2*r, sy-2*r], center=true);
}

module motor_body(){
    difference(){
        union(){
            rounded_box_xy([face_w, face_w, body_len], r=corner_r, center=true);
            translate([0,0, body_len/2 - front_flange_th/2])
                rounded_box_xy([face_w, face_w, front_flange_th], r=corner_r, center=true);
            translate([0,0, -body_len/2 + rear_cap_th/2])
                rounded_box_xy([face_w, face_w, rear_cap_th], r=corner_r, center=true);
            translate([0,0, body_len/2 + pilot_h/2])
                cylinder(d=pilot_d, h=pilot_h, center=true);
            translate([0,0, body_len/2 + pilot_h + shaft_len/2])
                cylinder(d=shaft_d, h=shaft_len, center=true);
        }
        for(x=[-mount_spacing/2, mount_spacing/2])
            for(y=[-mount_spacing/2, mount_spacing/2])
                translate([x,y, body_len/2 - front_flange_th/2])
                    cylinder(d=mount_hole_d, h=front_flange_th+0.6, center=true);
    }
}

motor_body();