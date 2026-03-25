difference() {
    cube([38.1, 25.4, 1.6], center=true);
    translate([0, 0, -0.8])
        cube([38.1 - 2*1.6, 25.4 - 2*1.6, 1.6 + 1.6], center=true);
}