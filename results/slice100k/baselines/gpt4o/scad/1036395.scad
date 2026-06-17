module gear_tooth() {
    translate([11.75, 0, 0])
    cube([2, 3, 7], center=true);
}

module gear() {
    difference() {
        cylinder(d=23.5, h=7, center=true, $fn=64);
        cylinder(d=10, h=7, center=true, $fn=64);
    }
}

module toothed_gear() {
    gear();
    for (i = [0:11]) {
        rotate([0, 0, i * 30])
        gear_tooth();
    }
}

toothed_gear();