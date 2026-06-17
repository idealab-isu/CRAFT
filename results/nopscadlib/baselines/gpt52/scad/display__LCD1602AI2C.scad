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

module standoff(h=6, od=6, hole=3.2){
    difference(){
        cylinder(h=h, d=od, center=false);
        translate([0,0,-0.2]) cylinder(h=h+0.4, d=hole, center=false);
    }
}

module lcd1602a_module(board_w=71.3, board_h=24.3, board_t=1.6){
    corner_r = 1.5;

    hole_d = 3.2;
    hole_x = 66.0;
    hole_y = 19.0;

    bezel_w = 64.5;
    bezel_h = 16.0;
    bezel_t = 3.0;

    window_w = 56.0;
    window_h = 12.0;

    header_pins = 16;
    header_pitch = 2.54;
    header_row_len = (header_pins-1)*header_pitch;
    header_body_w = header_row_len + 2.0;
    header_body_d = 5.0;
    header_body_h = 3.0;
    header_pin_d = 0.7;
    header_pin_h = 6.0;

    standoff_h = 6.0;
    standoff_od = 6.0;

    union(){
        color([0.05,0.35,0.10])
        difference(){
            linear_extrude(height=board_t, center=true)
                rounded_rect_2d(board_w, board_h, corner_r);

            for (sx=[-1,1], sy=[-1,1])
                translate([sx*hole_x/2, sy*hole_y/2, 0])
                    cylinder(h=board_t+0.6, d=hole_d, center=true);
        }

        for (sx=[-1,1], sy=[-1,1])
            translate([sx*hole_x/2, sy*hole_y/2, board_t/2])
                color([0.85,0.85,0.85])
                standoff(h=standoff_h, od=standoff_od, hole=hole_d);

        color([0.15,0.15,0.15])
        translate([0,0,board_t/2 + bezel_t/2])
        difference(){
            cube([bezel_w, bezel_h, bezel_t], center=true);
            translate([0,0,0])
                cube([window_w, window_h, bezel_t+0.4], center=true);
        }

        header_y = -board_h/2 + 3.5;
        header_z = board_t/2 + header_body_h/2;

        color([0.05,0.05,0.05])
        translate([0, header_y, header_z])
            cube([header_body_w, header_body_d, header_body_h], center=true);

        for(i=[0:header_pins-1]){
            x = -header_row_len/2 + i*header_pitch;
            color([0.85,0.75,0.20])
            translate([x, header_y, board_t/2 - header_pin_h/2])
                cylinder(h=header_pin_h, d=header_pin_d, center=true);
        }
    }
}

lcd1602a_module();