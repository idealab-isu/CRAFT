$fn=64;

rail_w = 15.0;
rail_h = 10.0;
rail_l = 100.0;

edge_chamfer = 1.0;

slot_w = 6.0;
slot_depth = 2.0;

hole_d = 3.2;
hole_csk_d = 6.0;
hole_csk_h = 2.0;
hole_pitch = 25.0;
hole_count = 4;

module chamfered_block(w,h,l,c){
    difference(){
        cube([l,w,h], center=true);
        for (sx=[-1,1], sy=[-1,1]) {
            translate([0, sy*(w/2), sx*(h/2)])
                rotate([0,90,0])
                    linear_extrude(height=l+2, center=true)
                        polygon(points=[[0,0],[c,0],[0,c]]);
        }
    }
}

module counterbore_hole(d_thru, d_cb, h_cb, h_total){
    union(){
        cylinder(d=d_thru, h=h_total+2, center=true);
        translate([0,0,(h_total/2)-(h_cb/2)])
            cylinder(d=d_cb, h=h_cb+0.2, center=true);
    }
}

module rail(){
    difference(){
        chamfered_block(rail_w, rail_h, rail_l, edge_chamfer);

        translate([0,0,(rail_h/2)-(slot_depth/2)])
            cube([rail_l+2, slot_w, slot_depth+0.2], center=true);

        for(i=[0:hole_count-1]){
            x = -rail_l/2 + hole_pitch/2 + i*hole_pitch;
            translate([x,0,0])
                counterbore_hole(hole_d, hole_csk_d, hole_csk_h, rail_h);
        }
    }
}

rail();