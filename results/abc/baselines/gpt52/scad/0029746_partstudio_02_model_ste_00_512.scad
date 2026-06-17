$fn=64;

L = 0.2;
W = 0.06;
H = 0.1;

t_base = 0.012;
t_web  = 0.010;

slot_len = 0.12;
slot_w   = 0.018;
slot_r   = slot_w/2;

diamond_w = 0.016;
diamond_l = 0.024;

end_offset = 0.065;
hole_y = 0.018;

tri_cut_len = 0.07;
tri_cut_h   = 0.055;
tri_cut_w   = 0.040;

center_diamond_w = 0.014;
center_diamond_l = 0.020;

module rounded_slot(len, w, r, h){
    linear_extrude(height=h, center=true)
        hull(){
            translate([-(len/2 - r), 0]) circle(r=r);
            translate([ (len/2 - r), 0]) circle(r=r);
        }
}

module diamond2d(l, w){
    polygon(points=[
        [ l/2, 0],
        [ 0,  w/2],
        [-l/2, 0],
        [ 0, -w/2]
    ]);
}

module diamond_hole(l, w, h){
    linear_extrude(height=h, center=true) diamond2d(l, w);
}

module tri_prism_x(len, w, h){
    linear_extrude(height=len, center=true)
        polygon(points=[
            [-w/2, 0],
            [ w/2, 0],
            [ 0,   h]
        ]);
}

module rail_solid(){
    union(){
        translate([0,0,-H/2 + t_base/2])
            cube([L, W, t_base], center=true);

        translate([0,0,-H/2 + t_base])
            rotate([0,90,0])
                linear_extrude(height=L, center=true)
                    polygon(points=[
                        [-W/2, 0],
                        [ W/2, 0],
                        [ 0,   H - t_base]
                    ]);
    }
}

module rail_cuts(){
    union(){
        translate([0,0,0])
            rounded_slot(slot_len, slot_w, slot_r, H+0.02);

        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*end_offset, sy*hole_y, 0])
                diamond_hole(diamond_l, diamond_w, H+0.02);
        }

        for (sx=[-1,1]){
            translate([sx*(L/2 - tri_cut_len/2 - 0.01), 0, -H/2 + t_base + 0.002])
                rotate([0,90,0])
                    tri_prism_x(tri_cut_len, tri_cut_w, tri_cut_h);
        }

        translate([0,0,0])
            diamond_hole(center_diamond_l, center_diamond_w, H+0.02);
    }
}

difference(){
    rail_solid();
    rail_cuts();
}