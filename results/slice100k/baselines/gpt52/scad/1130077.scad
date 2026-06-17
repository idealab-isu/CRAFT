$fn=64;

bbox_x = 52.3;
bbox_y = 50.0;
bbox_z = 38.8;

th = 2.0;

base_len = 40.0;
tab_len  = bbox_x - base_len; // 12.3

base_w = bbox_y;              // 50
tab_w  = 22.0;

base_t = th;
tab_t  = th;

wall_len = base_len;
wall_h = bbox_z - base_t;     // 36.8
wall_t = th;

inner_bottom_w = 18.0;
outer_bottom_w = inner_bottom_w + 2*wall_t;

outer_top_w = bbox_y;         // 50
inner_top_w = outer_top_w - 2*wall_t;

hole_d = 6.5;
hole_x_from_tab_end = 6.0;

module trapezoid_prism(len, w1, w2, h){
    linear_extrude(height=len, center=false, convexity=10)
        polygon(points=[
            [-w1/2, 0],
            [ w1/2, 0],
            [ w2/2, h],
            [-w2/2, h]
        ]);
}

module v_channel(){
    difference(){
        translate([-base_len/2, 0, 0])
            trapezoid_prism(base_len, outer_bottom_w, outer_top_w, wall_h);
        translate([-base_len/2, 0, wall_t])
            trapezoid_prism(base_len, inner_bottom_w, inner_top_w, wall_h - wall_t);
    }
}

module base_plate(){
    translate([-base_len/2, -base_w/2, 0])
        cube([base_len, base_w, base_t], center=false);
}

module mounting_tab(){
    difference(){
        translate([base_len/2, -tab_w/2, 0])
            cube([tab_len, tab_w, tab_t], center=false);
        translate([base_len/2 + hole_x_from_tab_end, 0, -1])
            cylinder(d=hole_d, h=tab_t+2, center=false);
    }
}

union(){
    base_plate();
    v_channel();
    mounting_tab();
}