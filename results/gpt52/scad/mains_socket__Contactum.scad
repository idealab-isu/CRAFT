$fn=64;

plate_w = 86;
plate_h = 86;
plate_t = 3;

backbox_w = 70;
backbox_h = 70;
backbox_d = 25;

face_r = 3;

socket_body_w = 50;
socket_body_h = 50;
socket_body_t = 6;

recess_w = 44;
recess_h = 44;
recess_d = 2.2;

earth_d = 6.5;
live_d = 6.0;
pin_depth = 6;

pin_spacing = 22.0;
earth_offset_y = 12.0;
live_offset_y = -8.0;

screw_hole_d = 4.2;
screw_csk_d = 8.5;
screw_csk_h = 1.6;
screw_offset_y = 28;

module rounded_plate(w,h,t,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(w/2-r), sy*(h/2-r), 0])
                cylinder(h=t, r=r);
    }
}

module screw_hole(){
    union(){
        cylinder(h=plate_t+0.5, d=screw_hole_d);
        translate([0,0,plate_t - screw_csk_h])
            cylinder(h=screw_csk_h+0.6, d1=screw_csk_d, d2=screw_hole_d);
    }
}

module pin_hole(d, depth){
    translate([0,0,plate_t - depth])
        cylinder(h=depth+0.6, d=d);
}

module socket_front_features(){
    translate([0,0,plate_t - recess_d])
        cube([recess_w, recess_h, recess_d+0.6], center=true);

    translate([0, earth_offset_y, 0]) pin_hole(earth_d, pin_depth);
    translate([-pin_spacing/2, live_offset_y, 0]) pin_hole(live_d, pin_depth);
    translate([ pin_spacing/2, live_offset_y, 0]) pin_hole(live_d, pin_depth);

    translate([0, screw_offset_y, 0]) screw_hole();
    translate([0,-screw_offset_y, 0]) screw_hole();
}

module socket_body(){
    translate([0,0,plate_t])
        cube([socket_body_w, socket_body_h, socket_body_t], center=false);
}

module backbox(){
    translate([-backbox_w/2, -backbox_h/2, plate_t])
        cube([backbox_w, backbox_h, backbox_d], center=false);
}

difference(){
    union(){
        rounded_plate(plate_w, plate_h, plate_t, face_r);
        socket_body();
        backbox();
    }
    socket_front_features();
}