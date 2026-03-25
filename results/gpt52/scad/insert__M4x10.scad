$fn=96;

insert_od = 10.0;
insert_len = 8.0;

screw_nominal = 4.0;
pilot_d = 4.2;

thread_pitch = 0.7;
thread_depth = 0.35;

knurl_count = 24;
knurl_depth = 0.35;

lead_in = 0.8;
chamfer = 0.6;

module internal_thread(d_minor, pitch, depth, length) {
    turns = length / pitch;
    linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*24), 60), convexity=10)
        translate([d_minor/2, 0, 0])
            circle(r=depth, $fn=24);
}

module knurl_ridges(od, length, count, depth) {
    r = od/2;
    for (i = [0:count-1]) {
        rotate([0,0,i*360/count])
            translate([r - depth/2, 0, 0])
                cube([depth, 0.9, length], center=true);
    }
}

module heat_set_insert(od, length, pilot_d, pitch, tdepth) {
    difference() {
        union() {
            difference() {
                cylinder(d=od, h=length, center=true);
                knurl_ridges(od=od, length=length*0.92, count=knurl_count, depth=knurl_depth);
            }
            translate([0,0,length/2 - lead_in/2])
                cylinder(d1=od-2*chamfer, d2=od, h=lead_in, center=true);
            translate([0,0,-length/2 + lead_in/2])
                cylinder(d1=od, d2=od-2*chamfer, h=lead_in, center=true);
        }

        cylinder(d=pilot_d, h=length+0.4, center=true);

        translate([0,0,-length/2])
            internal_thread(d_minor=pilot_d, pitch=pitch, depth=tdepth, length=length);
    }
}

heat_set_insert(od=insert_od, length=insert_len, pilot_d=pilot_d, pitch=thread_pitch, tdepth=thread_depth);