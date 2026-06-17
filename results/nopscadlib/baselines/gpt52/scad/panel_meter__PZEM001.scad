$fn=64;

meter_body_w = 80;
meter_body_h = 43;
meter_body_d = 25;

front_bezel_w = 85;
front_bezel_h = 45;
front_bezel_t = 3;

face_recess_w = 76;
face_recess_h = 39;
face_recess_d = 1.2;

screen_w = 46;
screen_h = 26;
screen_d = 1.6;

button_d = 6.5;
button_h = 2.2;

tab_w = 10;
tab_h = 6;
tab_t = 2.5;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d, center=true)
        rounded_rect_2d(w,h,r);
}

module bezel(){
    difference(){
        translate([0,0,(meter_body_d/2 + front_bezel_t/2)])
            rounded_box(front_bezel_w, front_bezel_h, front_bezel_t, 2.0);

        translate([0,0,(meter_body_d/2 + front_bezel_t/2) + (front_bezel_t/2 - face_recess_d/2)])
            rounded_box(face_recess_w, face_recess_h, face_recess_d+0.02, 1.5);

        translate([0,0,(meter_body_d/2 + front_bezel_t/2) + (front_bezel_t/2 - screen_d/2)])
            rounded_box(screen_w, screen_h, screen_d+0.02, 1.2);
    }
}

module body(){
    union(){
        rounded_box(meter_body_w, meter_body_h, meter_body_d, 1.5);

        translate([-(meter_body_w/2 + tab_t/2), 0, 0])
            rounded_box(tab_t, tab_h, tab_w, 0.8);

        translate([(meter_body_w/2 + tab_t/2), 0, 0])
            rounded_box(tab_t, tab_h, tab_w, 0.8);
    }
}

module button(){
    translate([0,0,(meter_body_d/2 + front_bezel_t) - 0.2])
        cylinder(d=button_d, h=button_h, center=false);
}

module panel_meter(){
    union(){
        body();
        bezel();
        translate([front_bezel_w/2 - 10, -front_bezel_h/2 + 10, 0]) button();
    }
}

panel_meter();