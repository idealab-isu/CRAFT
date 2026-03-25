module heatshrink_sleeving(outer_diameter=10, thickness=1, length=50) {
    difference() {
        cylinder(h=length, d=outer_diameter, $fn=64);
        translate([0, 0, -1])
            cylinder(h=length + 2, d=outer_diameter - 2 * thickness, $fn=64);
    }
}

heatshrink_sleeving();