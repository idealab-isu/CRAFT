$fn=64;

module iec_lugless_body(w=27.0, h=20.0, d=15.0, r=2.0){
    minkowski(){
        cube([w-2*r, h-2*r, d-2*r], center=true);
        sphere(r=r);
    }
}

module iec_lugless_faceplate(w=30.0, h=23.0, t=2.0, r=2.0){
    minkowski(){
        cube([w-2*r, h-2*r, t-2*r], center=true);
        sphere(r=r);
    }
}

module iec_lugless_cutout(w=24.0, h=16.0, d=30.0, r=1.2){
    minkowski(){
        cube([w-2*r, h-2*r, d-2*r], center=true);
        sphere(r=r);
    }
}

module iec_lugless_pin_hole(d=3.6, depth=30.0){
    cylinder(d=d, h=depth, center=true);
}

module iec_lugless(){
    body_w=27.0;
    body_h=20.0;
    body_d=15.0;

    face_w=30.0;
    face_h=23.0;
    face_t=2.0;

    cut_w=24.0;
    cut_h=16.0;

    pin_d=3.6;
    pin_pitch_x=10.0;
    pin_pitch_y=7.0;

    union(){
        difference(){
            union(){
                translate([0,0,0]) iec_lugless_body(w=body_w,h=body_h,d=body_d,r=2.0);
                translate([0,0,(body_d/2 + face_t/2)]) iec_lugless_faceplate(w=face_w,h=face_h,t=face_t,r=2.0);
            }

            translate([0,0,0]) iec_lugless_cutout(w=cut_w,h=cut_h,d=body_d+face_t+10.0,r=1.2);

            translate([0,0,0]){
                translate([-pin_pitch_x/2,  pin_pitch_y/2, 0]) iec_lugless_pin_hole(d=pin_d, depth=body_d+face_t+20.0);
                translate([ pin_pitch_x/2,  pin_pitch_y/2, 0]) iec_lugless_pin_hole(d=pin_d, depth=body_d+face_t+20.0);
                translate([0,             -pin_pitch_y/2, 0]) iec_lugless_pin_hole(d=pin_d, depth=body_d+face_t+20.0);
            }
        }
    }
}

iec_lugless();