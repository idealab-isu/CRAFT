$fn=64;

rail_w = 15.0;
rail_h = 12.5;
rail_l = 100.0;

module countersunk_hole(h=20, d_shaft=3.4, d_head=6.6, head_h=2.2) {
    union() {
        cylinder(h=h, d=d_shaft, center=true);
        translate([0,0,(h/2)-(head_h/2)]) cylinder(h=head_h, d1=d_head, d2=d_shaft, center=true);
    }
}

module rail_profile(len=rail_l, w=rail_w, h=rail_h) {
    base_h = 8.0;
    top_h = h - base_h;
    top_w = 10.0;
    cham = 1.0;

    difference() {
        union() {
            translate([0,0,-h/2 + base_h/2]) cube([w, len, base_h], center=true);
            translate([0,0,-h/2 + base_h + top_h/2]) cube([top_w, len, top_h], center=true);
        }

        for (sx=[-1,1]) {
            translate([sx*(w/2 - cham/2), 0, -h/2 + cham/2])
                rotate([0,45,0]) cube([cham, len+2, cham], center=true);
        }

        for (sx=[-1,1]) {
            translate([sx*(top_w/2 - cham/2), 0, h/2 - cham/2])
                rotate([0,45,0]) cube([cham, len+2, cham], center=true);
        }
    }
}

module mounting_holes(len=rail_l) {
    hole_count = 5;
    end_margin = 12.0;
    y0 = -len/2 + end_margin;
    y1 =  len/2 - end_margin;

    for (i=[0:hole_count-1]) {
        y = (hole_count==1) ? 0 : (y0 + (y1-y0)*i/(hole_count-1));
        translate([0, y, -rail_h/2 + 4.0])
            rotate([90,0,0]) countersunk_hole(h=rail_w+6, d_shaft=3.4, d_head=6.6, head_h=2.2);
    }
}

difference() {
    rail_profile();
    mounting_holes();
}