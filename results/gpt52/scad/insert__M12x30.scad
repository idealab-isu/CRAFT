$fn=128;

od = 30.0;
len = 22.0;
screw_d = 12.0;

wall = 2.2;
id = screw_d + 0.6;

pitch = 2.5;
thread_depth = 0.9;
thread_starts = 1;

knurl_count = 36;
knurl_depth = 0.7;

chamfer_h = 1.2;
chamfer_delta = 1.2;

module internal_thread(d_minor, d_major, L, p, depth, starts=1) {
    turns = L / p;
    for (s = [0:starts-1]) {
        rotate([0,0, s*360/starts])
            linear_extrude(height=L, twist=turns*360, slices=max(ceil(turns*48), 24), convexity=10)
                translate([d_minor/2, 0, 0])
                    polygon(points=[
                        [0, -p*0.22],
                        [depth, 0],
                        [0,  p*0.22]
                    ]);
    }
}

module knurl_cutouts(outer_d, L, count, depth) {
    r = outer_d/2 - depth/2;
    w = (2*PI*(outer_d/2))/count * 0.55;
    h = L*0.85;
    for (i = [0:count-1]) {
        rotate([0,0, i*360/count])
            translate([r, 0, 0])
                rotate([0,0,45])
                    cube([depth, w, h], center=true);
    }
}

module insert_body() {
    difference() {
        union() {
            cylinder(d=od, h=len, center=true);
            translate([0,0, len/2 - chamfer_h/2])
                cylinder(d1=od, d2=od - 2*chamfer_delta, h=chamfer_h, center=true);
            translate([0,0, -len/2 + chamfer_h/2])
                cylinder(d1=od - 2*chamfer_delta, d2=od, h=chamfer_h, center=true);
        }

        translate([0,0,0])
            cylinder(d=id, h=len+2, center=true);

        translate([0,0,-len/2-0.01])
            internal_thread(d_minor=id, d_major=id + 2*thread_depth, L=len+0.02, p=pitch, depth=thread_depth, starts=thread_starts);

        knurl_cutouts(od, len, knurl_count, knurl_depth);
    }
}

insert_body();