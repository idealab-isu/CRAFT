$fn=96;

od = 4.0;
len = 3.6;
screw_d = 2.0;

module knurl_ring(r=2, h=1, teeth=24, depth=0.25, twist=18) {
    difference() {
        cylinder(r=r, h=h, center=true);
        for (i=[0:teeth-1]) {
            rotate([0,0,i*360/teeth])
                translate([r - depth/2, 0, 0])
                    rotate([0,0,45])
                        cube([depth, depth, h*1.2], center=true);
        }
        linear_extrude(height=h*1.05, center=true, twist=twist, slices=40)
            translate([r - depth*0.9, 0, 0])
                square([depth*1.2, depth*0.9], center=true);
        linear_extrude(height=h*1.05, center=true, twist=-twist, slices=40)
            translate([r - depth*0.9, 0, 0])
                square([depth*1.2, depth*0.9], center=true);
    }
}

module heat_set_insert(od=4.0, len=3.6, screw_d=2.0) {
    r = od/2;
    bore_d = screw_d * 0.85;
    lead_in = 0.35;
    mid_h = max(0.1, len - 2*lead_in);

    difference() {
        union() {
            translate([0,0,0])
                knurl_ring(r=r, h=mid_h, teeth=28, depth=0.28, twist=22);

            translate([0,0,(mid_h/2 + lead_in/2)])
                cylinder(r1=r*0.92, r2=r, h=lead_in, center=true);

            translate([0,0,-(mid_h/2 + lead_in/2)])
                cylinder(r1=r, r2=r*0.92, h=lead_in, center=true);
        }

        union() {
            cylinder(d=bore_d, h=len+0.6, center=true);

            translate([0,0,len/2 - 0.55])
                cylinder(d1=bore_d*1.6, d2=bore_d, h=0.7, center=true);

            translate([0,0,-len/2 + 0.55])
                cylinder(d1=bore_d, d2=bore_d*1.6, h=0.7, center=true);
        }
    }
}

heat_set_insert(od=od, len=len, screw_d=screw_d);