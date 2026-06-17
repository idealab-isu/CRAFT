$fn=96;

od = 8.0;
len = 6.0;
screw_d = 3.0;

module knurl_ridges(od, len, ridge_h=0.35, ridge_w=0.55, count=24, twist=18) {
    for (i = [0:count-1]) {
        rotate([0,0, i*360/count])
            linear_extrude(height=len, twist=twist, slices=80, convexity=10)
                translate([od/2 - ridge_h, 0, 0])
                    square([ridge_h, ridge_w], center=true);
    }
}

module heat_set_insert(od=8.0, len=6.0, screw_d=3.0) {
    base_d = od - 0.8;
    bore_d = screw_d - 0.2;
    lead_in = 0.6;

    difference() {
        union() {
            cylinder(d=base_d, h=len, center=true);
            knurl_ridges(od=od, len=len, ridge_h=0.35, ridge_w=0.55, count=24, twist=18);
            translate([0,0, len/2 - lead_in/2]) cylinder(d1=od, d2=base_d, h=lead_in, center=true);
            translate([0,0,-len/2 + lead_in/2]) cylinder(d1=base_d, d2=od, h=lead_in, center=true);
        }
        cylinder(d=bore_d, h=len+2, center=true);
        translate([0,0, len/2 - lead_in/2]) cylinder(d1=bore_d+1.0, d2=bore_d, h=lead_in+0.2, center=true);
        translate([0,0,-len/2 + lead_in/2]) cylinder(d1=bore_d, d2=bore_d+1.0, h=lead_in+0.2, center=true);
    }
}

heat_set_insert(od=od, len=len, screw_d=screw_d);