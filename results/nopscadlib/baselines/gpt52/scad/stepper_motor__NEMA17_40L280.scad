$fn=96;

face_w = 42.3;
body_len = 40.0;

shaft_d = 8.0;
shaft_len = 20.0;

mount_spacing = 31.0;
mount_hole_d = 3.2;

front_plate_th = 3.0;
boss_d = 22.0;
boss_h = 2.0;

corner_r = 4.0;

module rounded_square_prism(w, h, r, t){
    linear_extrude(height=t, center=true)
        offset(r=r)
            square([w-2*r, h-2*r], center=true);
}

module motor_body(){
    translate([0,0,0])
        rounded_square_prism(face_w, face_w, corner_r, body_len);
}

module front_plate(){
    translate([0,0, body_len/2 - front_plate_th/2])
        rounded_square_prism(face_w, face_w, corner_r, front_plate_th);
}

module pilot_boss(){
    translate([0,0, body_len/2 + boss_h/2])
        cylinder(d=boss_d, h=boss_h, center=true);
}

module shaft(){
    translate([0,0, body_len/2 + boss_h + shaft_len/2])
        cylinder(d=shaft_d, h=shaft_len, center=true);
}

module mounting_holes(){
    zc = body_len/2 - front_plate_th/2;
    for (x = [-mount_spacing/2, mount_spacing/2])
        for (y = [-mount_spacing/2, mount_spacing/2])
            translate([x,y,zc])
                cylinder(d=mount_hole_d, h=front_plate_th+0.6, center=true);
}

module stepper_motor(){
    difference(){
        union(){
            motor_body();
            front_plate();
            pilot_boss();
            shaft();
        }
        mounting_holes();
    }
}

stepper_motor();