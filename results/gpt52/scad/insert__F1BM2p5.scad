$fn=96;

od = 5.8;
len = 4.6;
screw_d = 2.5;

id = 3.2;
pitch = 0.45;
thread_depth = 0.25;

chamfer = 0.35;
knurl_count = 18;
knurl_depth = 0.25;

module internal_thread(d_minor, pitch, depth, h) {
    turns = h / pitch;
    linear_extrude(height=h, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
        translate([d_minor/2, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0, pitch*0.22]
            ]);
}

module knurl_ridges(od, h, count, depth) {
    for (i = [0:count-1]) {
        rotate([0,0, i*360/count])
            translate([od/2 - depth/2, 0, h/2])
                cube([depth, 0.9, h], center=true);
    }
}

module heat_set_insert() {
    difference() {
        union() {
            difference() {
                cylinder(d=od, h=len, center=true);
                knurl_ridges(od, len, knurl_count, knurl_depth);
            }
            translate([0,0, len/2 - chamfer/2])
                cylinder(d1=od, d2=od-2*chamfer, h=chamfer, center=true);
            translate([0,0, -len/2 + chamfer/2])
                cylinder(d1=od-2*chamfer, d2=od, h=chamfer, center=true);
        }

        cylinder(d=id, h=len+0.6, center=true);

        translate([0,0,-len/2])
            internal_thread(d_minor=id, pitch=pitch, depth=thread_depth, h=len);

        translate([0,0, len/2 - 0.6/2])
            cylinder(d1=id+0.8, d2=id, h=0.6, center=true);
        translate([0,0, -len/2 + 0.6/2])
            cylinder(d1=id, d2=id+0.8, h=0.6, center=true);
    }
}

heat_set_insert();