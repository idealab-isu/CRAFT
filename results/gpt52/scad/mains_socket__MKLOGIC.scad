$fn=64;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module rounded_box(w,h,t,r){
    linear_extrude(height=t, center=true) rounded_rect_2d(w,h,r);
}

module screw_hole(d=4.2, head_d=8.5, head_h=2.2, t=6){
    union(){
        cylinder(d=d, h=t+2, center=true);
        translate([0,0,t/2 - head_h/2]) cylinder(d=head_d, h=head_h+0.2, center=true);
    }
}

module rocker_switch(w=22, h=14, t=2.2, r=2){
    difference(){
        rounded_box(w,h,t,r);
        translate([0,0,0]) linear_extrude(height=t+0.4, center=true)
            offset(delta=-1.2) rounded_rect_2d(w,h,r);
    }
}

module socket_aperture_pair(center_x, y, w=14, h=18, r=2, t=20){
    translate([center_x, y, 0])
        linear_extrude(height=t, center=true)
            rounded_rect_2d(w,h,r);
}

module uk_socket_faceplate(){
    plate_w = 146;
    plate_h = 86;
    plate_t = 6;
    plate_r = 6;

    inner_w = 132;
    inner_h = 72;
    inner_t = 1.2;
    inner_r = 5;

    screw_dx = 120;
    screw_dy = 60;

    // Socket apertures
    ap_w = 14;
    ap_h = 18;
    ap_r = 2;
    ap_y = -2;
    ap_dx = 38;

    // Switch cutout
    sw_w = 24;
    sw_h = 16;
    sw_y = 26;

    // Neon indicator
    neon_d = 5;
    neon_y = 26;

    difference(){
        union(){
            rounded_box(plate_w, plate_h, plate_t, plate_r);
            translate([0,0,plate_t/2 - inner_t/2])
                rounded_box(inner_w, inner_h, inner_t, inner_r);

            // Raised switch rocker
            translate([0, sw_y, plate_t/2 + 0.9])
                rocker_switch(w=22, h=14, t=2.0, r=2);
        }

        // Screw holes
        translate([ screw_dx/2,  screw_dy/2, 0]) screw_hole(d=4.2, head_d=8.5, head_h=2.2, t=plate_t);
        translate([-screw_dx/2,  screw_dy/2, 0]) screw_hole(d=4.2, head_d=8.5, head_h=2.2, t=plate_t);
        translate([ screw_dx/2, -screw_dy/2, 0]) screw_hole(d=4.2, head_d=8.5, head_h=2.2, t=plate_t);
        translate([-screw_dx/2, -screw_dy/2, 0]) screw_hole(d=4.2, head_d=8.5, head_h=2.2, t=plate_t);

        // Socket apertures (double)
        socket_aperture_pair(-ap_dx/2, ap_y, w=ap_w, h=ap_h, r=ap_r, t=plate_t+4);
        socket_aperture_pair( ap_dx/2, ap_y, w=ap_w, h=ap_h, r=ap_r, t=plate_t+4);

        // Switch cutout (around rocker)
        translate([0, sw_y, 0])
            linear_extrude(height=plate_t+4, center=true)
                rounded_rect_2d(sw_w, sw_h, 2);

        // Neon indicator hole
        translate([0, neon_y, 0]) cylinder(d=neon_d, h=plate_t+6, center=true);
    }
}

uk_socket_faceplate();