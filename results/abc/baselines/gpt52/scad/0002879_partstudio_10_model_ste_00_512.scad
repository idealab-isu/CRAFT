$fn=96;

L = 0.4;
W = 0.1;
H = 0.3;

module arc_rib(r_in, r_out, ang, h, center=true){
    rotate([0,0,-ang/2])
    rotate_extrude(angle=ang, convexity=10)
        translate([(r_in+r_out)/2,0,0])
            square([r_out-r_in, h], center=center);
}

module end_block(thick, w, h, x_pos){
    translate([x_pos,0,0])
        cube([thick,w,h], center=true);
}

module peg_tab(x_pos, peg_d, peg_len, tab_w, tab_h, tab_len){
    translate([x_pos,0,0]){
        translate([0,0,0])
            rotate([0,90,0])
                cylinder(d=peg_d, h=peg_len, center=true);
        translate([peg_len/2 + tab_len/2, 0, 0])
            cube([tab_len, tab_w, tab_h], center=true);
    }
}

module bracket(){
    ang = 150;
    r_out = 0.19;
    rib_t = 0.018;
    gap = 0.028;
    r_mid = r_out - rib_t - gap;
    r_in = r_mid - rib_t;

    rib_h = H;
    slot_h = H*0.78;

    union(){
        // Main curved ribs with tapered slot
        difference(){
            union(){
                arc_rib(r_out-rib_t, r_out, ang, rib_h, center=true);
                arc_rib(r_in, r_in+rib_t, ang, rib_h, center=true);
            }

            // Long tapered slot between ribs
            rotate([0,0,-ang/2])
            rotate_extrude(angle=ang, convexity=10)
                translate([r_in+rib_t + gap/2, 0, 0])
                    polygon(points=[
                        [-gap*0.65, -slot_h/2],
                        [ gap*0.65, -slot_h/2],
                        [ gap*0.35,  slot_h/2],
                        [-gap*0.35,  slot_h/2]
                    ]);

            // Open the "C" mouth a bit more
            rotate([0,0,ang/2])
                translate([0,0,0])
                    cube([0.5,0.5,0.5], center=true);
        }

        // End blocks: one thicker, one thinner/tapered
        x_thick = r_out*cos(ang/2);
        y_thick = r_out*sin(ang/2);

        x_thin  = r_out*cos(-ang/2);
        y_thin  = r_out*sin(-ang/2);

        // Thicker end block
        translate([x_thick, y_thick, 0])
            rotate([0,0,ang/2])
                end_block(0.06, W*0.95, H*0.95, 0);

        // Peg/tab on thicker end
        translate([x_thick, y_thick, 0])
            rotate([0,0,ang/2])
                translate([0.03, 0, 0])
                    peg_tab(0, 0.018, 0.04, 0.03, 0.03, 0.03);

        // Thinner tapered end block
        translate([x_thin, y_thin, 0])
            rotate([0,0,-ang/2])
                hull(){
                    end_block(0.03, W*0.85, H*0.85, 0);
                    translate([0.02,0,0])
                        end_block(0.01, W*0.65, H*0.65, 0);
                }
    }
}

bracket();