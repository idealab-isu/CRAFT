$fn=128;

od = 30.0;
len = 25.0;
screw_d = 16.0;

wall = 2.0;
minor_d = screw_d - 2*wall;          // approximate internal minor diameter
pitch = 2.0;                          // approximate thread pitch
thread_depth = 1.2;                   // approximate thread depth
thread_clear = 0.25;                  // clearance for internal thread

knurl_count = 48;
knurl_depth = 0.8;
knurl_band_h = 18.0;

lead_in = 1.2;
chamfer = 0.8;

module internal_thread(d_major, pitch, depth, length, clearance=0.2) {
    turns = length / pitch;
    linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*24), 60), convexity=10)
        translate([d_major/2 - depth, 0, 0])
            circle(r=depth + clearance, $fn=24);
}

module knurl_ring(od, h, count, depth) {
    difference() {
        cylinder(d=od, h=h, center=true, $fn=128);
        for (i=[0:count-1]) {
            rotate([0,0,i*360/count])
                translate([od/2 - depth/2, 0, 0])
                    cube([depth, od*0.12, h*1.2], center=true);
        }
    }
}

module insert_body() {
    union() {
        cylinder(d=od, h=len, center=true, $fn=128);

        translate([0,0,0])
            knurl_ring(od=od, h=knurl_band_h, count=knurl_count, depth=knurl_depth);

        translate([0,0,len/2 - lead_in/2])
            cylinder(d1=od-2*chamfer, d2=od, h=lead_in, center=true, $fn=128);

        translate([0,0,-len/2 + lead_in/2])
            cylinder(d1=od, d2=od-2*chamfer, h=lead_in, center=true, $fn=128);
    }
}

module insert() {
    difference() {
        insert_body();

        // Core bore
        cylinder(d=minor_d + 0.6, h=len+2, center=true, $fn=128);

        // Internal helical thread (approximate)
        translate([0,0,-len/2])
            internal_thread(d_major=screw_d + thread_clear, pitch=pitch, depth=thread_depth, length=len);

        // Entry chamfers for screw
        translate([0,0,len/2 - 0.6])
            cylinder(d1=screw_d + 2.0, d2=minor_d + 0.6, h=1.2, center=true, $fn=128);

        translate([0,0,-len/2 + 0.6])
            cylinder(d1=minor_d + 0.6, d2=screw_d + 2.0, h=1.2, center=true, $fn=128);
    }
}

insert();