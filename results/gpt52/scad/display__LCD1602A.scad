$fn=64;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module standoff(h=3, od=6, id=3.2){
    difference(){
        cylinder(h=h, d=od);
        translate([0,0,-0.2]) cylinder(h=h+0.4, d=id);
    }
}

module lcd1602a_module(){
    pcb_w = 71.3;
    pcb_h = 24.3;
    pcb_t = 1.6;

    corner_r = 1.2;

    hole_d = 3.2;
    hole_x = 66.0;
    hole_y = 19.0;

    bezel_w = 64.0;
    bezel_h = 16.0;
    bezel_t = 2.2;

    window_w = 56.0;
    window_h = 12.0;

    header_pins = 16;
    header_pitch = 2.54;
    header_row_len = (header_pins-1)*header_pitch;
    header_body_w = header_row_len + 2.0;
    header_body_h = 5.0;
    header_body_t = 3.0;

    header_y = pcb_h/2 - 3.0;
    header_z = pcb_t;

    union(){
        difference(){
            linear_extrude(height=pcb_t)
                rounded_rect_2d(pcb_w, pcb_h, corner_r);

            for (sx=[-1,1], sy=[-1,1]){
                translate([sx*hole_x/2, sy*hole_y/2, -0.2])
                    cylinder(h=pcb_t+0.4, d=hole_d);
            }
        }

        translate([0,0,pcb_t])
        difference(){
            linear_extrude(height=bezel_t)
                rounded_rect_2d(bezel_w, bezel_h, 1.0);

            translate([0,0,-0.2])
                linear_extrude(height=bezel_t+0.4)
                    rounded_rect_2d(window_w, window_h, 0.8);
        }

        translate([0,0,pcb_t+0.2])
            color([0.1,0.1,0.1])
            linear_extrude(height=0.8)
                rounded_rect_2d(window_w-2.0, window_h-2.0, 0.6);

        translate([0, header_y, header_z])
            color([0.05,0.05,0.05])
            translate([0,0,header_body_t/2])
                cube([header_body_w, header_body_h, header_body_t], center=true);

        for(i=[0:header_pins-1]){
            x = -header_row_len/2 + i*header_pitch;
            translate([x, header_y, header_z])
                color([0.8,0.7,0.2])
                cylinder(h=6.0, d=0.8);
        }

        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*hole_x/2, sy*hole_y/2, -3.0])
                standoff(h=3.0, od=6.0, id=hole_d);
        }
    }
}

lcd1602a_module();