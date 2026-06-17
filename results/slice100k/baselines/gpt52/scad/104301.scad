$fn=64;

L = 105.1;
W = 9.7;
T = 12.0;

hole_d = 4.2;
hole_margin = 7.0;
hole_count = 7;

fork_depth = 18.0;
slot_w = 4.2;
tine_min = 2.0;
tine_w = max(tine_min, (W - slot_w)/2);

module strap_body() {
    translate([0,0,0]) cube([L, W, T], center=false);
}

module hole_pattern() {
    usable = L - 2*hole_margin;
    step = usable/(hole_count-1);
    for (i=[0:hole_count-1]) {
        x = hole_margin + i*step;
        translate([x, W/2, T/2])
            rotate([90,0,0])
                cylinder(h=W+2, d=hole_d, center=true);
    }
}

module fork_slot() {
    translate([0, (W-slot_w)/2, -1])
        cube([fork_depth, slot_w, T+2], center=false);
}

difference() {
    translate([-L/2, -W/2, -T/2]) strap_body();
    translate([-L/2, -W/2, -T/2]) hole_pattern();
    translate([-L/2, -W/2, -T/2]) fork_slot();
}