$fn=96;

od = 4.0;
len = 4.6;
id = 2.5;

knurl_depth = 0.25;
knurl_count = 24;
knurl_twist_deg = 35;

chamfer_h = 0.5;
chamfer_r = 0.35;

module chamfered_cylinder(h, r, ch_h, ch_r) {
    union() {
        translate([0,0,-h/2 + ch_h])
            cylinder(h=h-2*ch_h, r=r, center=false);
        translate([0,0,-h/2])
            cylinder(h=ch_h, r1=r-ch_r, r2=r, center=false);
        translate([0,0,h/2 - ch_h])
            cylinder(h=ch_h, r1=r, r2=r-ch_r, center=false);
    }
}

module knurl_cutters(h, r, depth, n, twist_deg) {
    for (i = [0:n-1]) {
        rotate([0,0, i*360/n])
            rotate([0,0, twist_deg])
                translate([r - depth/2, 0, 0])
                    cube([depth, 0.9, h+0.6], center=true);
    }
}

module heat_set_insert(od, len, id) {
    r = od/2;
    difference() {
        chamfered_cylinder(len, r, chamfer_h, chamfer_r);
        cylinder(h=len+1, r=id/2, center=true);
        knurl_cutters(len, r, knurl_depth, knurl_count, knurl_twist_deg);
        rotate([0,0,180/knurl_count])
            knurl_cutters(len, r, knurl_depth, knurl_count, -knurl_twist_deg);
    }
}

heat_set_insert(od, len, id);