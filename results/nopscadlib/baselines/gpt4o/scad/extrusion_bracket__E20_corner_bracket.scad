module extrusion_bracket() {
    difference() {
        cube([28, 28, 20], center = true);
        translate([-14, -14, -10])
            cube([20, 20, 20], center = false);
    }
}

extrusion_bracket();