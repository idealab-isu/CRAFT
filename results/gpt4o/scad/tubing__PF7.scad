module ptfe_tubing(outer_diameter=4, inner_diameter=2, length=100) {
    difference() {
        cylinder(d=outer_diameter, h=length, $fn=64);
        translate([0, 0, -1])
            cylinder(d=inner_diameter, h=length + 2, $fn=64);
    }
}

ptfe_tubing();