$fn=96;

outer_d = 23.5;
thickness = 7.0;

bore_d = 10.0;

lug_count = 12;
lug_radial = 1.6;
lug_tangential = 3.0;

module ring_body() {
    difference() {
        cylinder(h=thickness, d=outer_d, center=true);
        cylinder(h=thickness+0.4, d=bore_d, center=true);
    }
}

module lug() {
    translate([outer_d/2 - lug_radial/2, 0, 0])
        cube([lug_radial, lug_tangential, thickness], center=true);
}

module lugs() {
    for (i = [0:lug_count-1]) {
        rotate([0,0, i*360/lug_count]) lug();
    }
}

union() {
    ring_body();
    lugs();
}