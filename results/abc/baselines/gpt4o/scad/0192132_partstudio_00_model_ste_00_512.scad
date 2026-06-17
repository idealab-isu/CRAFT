module rounded_cylinder(diameter, height, fillet_radius, facets) {
    difference() {
        cylinder(d=diameter, h=height, $fn=facets);
        translate([0, 0, -fillet_radius])
            cylinder(d=diameter - 2 * fillet_radius, h=height + 2 * fillet_radius, $fn=facets);
    }
}

scale([0.1, 0.1, 0.1])
    rounded_cylinder(1, 1, 0.05, 64);