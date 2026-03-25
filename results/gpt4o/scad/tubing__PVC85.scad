module pvc_aquarium_tubing(outer_diameter=20, inner_diameter=18, length=100) {
    difference() {
        cylinder(h=length, d=outer_diameter, $fn=64);
        translate([0, 0, -1])
            cylinder(h=length + 2, d=inner_diameter, $fn=64);
    }
}

pvc_aquarium_tubing();