$fn=96;

L = 46.2;
W = 40.0;
T = 7.0;

chamfer_h = 0.8;
chamfer_inset = 0.9;

hole_d = 4.2;

groove_w = 6.0;
groove_depth = 1.2;
groove_angle = 28;

notch_w = 10.0;
notch_depth = 3.0;
notch_h = 2.2;

module hex_prism_flat(L, W, T){
    r = W/2;
    scale([L/W, 1, 1])
        cylinder(h=T, r=r, center=true, $fn=6);
}

module chamfered_hex(L, W, T, ch_h, inset){
    difference(){
        hex_prism_flat(L, W, T);
        translate([0,0, T/2 - ch_h/2])
            linear_extrude(height=ch_h, center=true, convexity=10)
                offset(delta=-inset)
                    scale([L/W, 1])
                        circle(r=W/2, $fn=6);
        translate([0,0,-T/2 + ch_h/2])
            linear_extrude(height=ch_h, center=true, convexity=10)
                offset(delta=-inset)
                    scale([L/W, 1])
                        circle(r=W/2, $fn=6);
    }
}

module diagonal_groove(L, W, depth, width, angle_deg){
    translate([0,0, T/2 - depth/2])
        rotate([0,0,angle_deg])
            cube([L*1.6, width, depth], center=true);
}

module end_notch(L, W, T, notch_w, notch_depth, notch_h){
    translate([L/2 - notch_depth/2, 0, -T/2 + notch_h/2])
        cube([notch_depth, notch_w, notch_h], center=true);
}

difference(){
    chamfered_hex(L, W, T, chamfer_h, chamfer_inset);

    cylinder(h=T+2, d=hole_d, center=true);

    diagonal_groove(L, W, groove_depth, groove_w, groove_angle);

    end_notch(L, W, T, notch_w, notch_depth, notch_h);
}