$fn=96;

bbox_x = 29.8;
bbox_y = 30.9;
thk = 6.0;

outer_r = bbox_y/2;          // 15.45
inner_d = 20.0;
inner_r = inner_d/2;

key_w = 3.0;
key_depth = 2.0;

pin_d = 2.0;
pin_h = 1.5;
pin_offset_from_edge = 2.2;

module oct_outer(h=thk, r=outer_r){
    cylinder(h=h, r=r, $fn=8, center=true);
}

module bore(h=thk+0.4, r=inner_r){
    cylinder(h=h, r=r, center=true);
}

module keyway_cuts(h=thk+0.6, r=inner_r, w=key_w, depth=key_depth){
    for (a=[0,180]){
        rotate([0,0,a])
            translate([r - depth/2, 0, 0])
                cube([depth, w, h], center=true);
    }
}

module pins(){
    y_edge = bbox_y/2;
    y_pin = y_edge - pin_offset_from_edge;
    x_sep = 6.0;
    for (x=[-x_sep/2, x_sep/2]){
        translate([x, y_pin, thk/2 + pin_h/2])
            cylinder(h=pin_h, d=pin_d, center=true);
    }
}

module ring_body(){
    difference(){
        oct_outer();
        bore();
        keyway_cuts();
    }
}

union(){
    ring_body();
    pins();
}