module neoprene_tubing(outer_diameter=20, inner_diameter=15, length=100) {
    difference() {
        cylinder(h=length, d=outer_diameter, $fn=64);
        translate([0, 0, -1])
            cylinder(h=length + 2, d=inner_diameter, $fn=64);
    }
}

neoprene_tubing();