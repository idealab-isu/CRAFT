module ptfe_heatshrink_sleeving(outer_diameter=10, inner_diameter=8, length=50) {
    difference() {
        cylinder(h=length, d=outer_diameter, $fn=64);
        translate([0, 0, -1])
            cylinder(h=length + 2, d=inner_diameter, $fn=64);
    }
}

ptfe_heatshrink_sleeving();