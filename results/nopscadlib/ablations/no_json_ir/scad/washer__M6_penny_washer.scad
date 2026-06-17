module penny_washer_body(outer_diameter, inner_diameter, thickness) {
    difference() {
        cylinder(h = thickness, d = outer_diameter, $fn=100);
        translate([0, 0, -1])
            cylinder(h = thickness + 2, d = inner_diameter, $fn=100);
    }
}

module penny_washer() {
    penny_washer_body(outer_diameter = 26.0, inner_diameter = 6.0, thickness = 1.5);
}

penny_washer();