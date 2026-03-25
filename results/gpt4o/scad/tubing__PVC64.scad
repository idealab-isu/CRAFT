module pvc_aquarium_tubing() {
    difference() {
        cylinder(h=100, r=10, $fn=64);
        translate([0, 0, -1])
            cylinder(h=102, r=8, $fn=64);
    }
}

pvc_aquarium_tubing();