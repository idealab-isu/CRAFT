$fn=64;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        for(x=[-w/2 + r2, w/2 - r2])
            for(y=[-h/2 + r2, h/2 - r2])
                translate([x,y]) circle(r=r2);
    }
}

module standoff(h=6, od=6, id=2.6){
    difference(){
        cylinder(h=h, d=od, center=false);
        translate([0,0,-0.2]) cylinder(h=h+0.4, d=id, center=false);
    }
}

module display_module_v3_0(w=84.5, h=54.5, t=1.6){
    corner_r = 3.0;

    hole_dx = 78.0;
    hole_dy = 48.0;
    hole_d  = 3.2;

    standoff_h = 6.0;
    standoff_od = 6.0;
    standoff_id = 2.6;

    window_w = 70.0;
    window_h = 40.0;
    window_r = 2.0;

    header_pins = 16;
    header_pitch = 2.54;
    header_row_len = (header_pins-1)*header_pitch;
    header_hole_d = 1.1;
    header_y = -h/2 + 6.0;
    header_x0 = -header_row_len/2;

    difference(){
        union(){
            linear_extrude(height=t, center=true)
                rounded_rect_2d(w,h,corner_r);

            for(x=[-hole_dx/2, hole_dx/2])
                for(y=[-hole_dy/2, hole_dy/2])
                    translate([x,y,t/2])
                        standoff(h=standoff_h, od=standoff_od, id=standoff_id);
        }

        for(x=[-hole_dx/2, hole_dx/2])
            for(y=[-hole_dy/2, hole_dy/2])
                translate([x,y,0])
                    cylinder(h=t+0.6, d=hole_d, center=true);

        translate([0,0,0])
            linear_extrude(height=t+0.8, center=true)
                rounded_rect_2d(window_w, window_h, window_r);

        for(i=[0:header_pins-1]){
            translate([header_x0 + i*header_pitch, header_y, 0])
                cylinder(h=t+0.6, d=header_hole_d, center=true);
        }
    }
}

display_module_v3_0();