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

module standoff(h=3.0, od=4.0, id=2.2){
    difference(){
        cylinder(h=h, d=od);
        translate([0,0,-0.1]) cylinder(h=h+0.2, d=id);
    }
}

module lcd_tft_128x160_module(board_w=46.0, board_h=34.0, board_t=1.6){
    bezel_t = 2.0;
    bezel_w = 30.0;
    bezel_h = 40.0;
    bezel_r = 1.5;

    view_w = 26.0;
    view_h = 35.0;

    standoff_h = 3.0;
    standoff_od = 4.0;
    standoff_id = 2.2;
    hole_edge = 2.5;
    hole_d = 2.2;

    union(){
        difference(){
            linear_extrude(height=board_t)
                rounded_rect_2d(board_w, board_h, 1.0);

            for (sx=[-1,1], sy=[-1,1])
                translate([sx*(board_w/2 - hole_edge), sy*(board_h/2 - hole_edge), -0.1])
                    cylinder(h=board_t+0.2, d=hole_d);
        }

        translate([0,0,board_t])
        difference(){
            linear_extrude(height=bezel_t)
                rounded_rect_2d(bezel_w, bezel_h, bezel_r);

            translate([0,0,-0.1])
                linear_extrude(height=bezel_t+0.2)
                    rounded_rect_2d(view_w, view_h, 0.8);
        }

        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(board_w/2 - hole_edge), sy*(board_h/2 - hole_edge), board_t])
                standoff(h=standoff_h, od=standoff_od, id=standoff_id);

        translate([0, -(board_h/2 - 4.0), -0.8])
            cube([18.0, 6.0, 1.6], center=true);
    }
}

lcd_tft_128x160_module();