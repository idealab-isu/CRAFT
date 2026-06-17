module extrusion_bracket() {
    difference() {
        cube([26, 25, 4.7], center = true);
        translate([-13, -12.5, -2.35])
            cube([20, 20, 4.7], center = true);
    }
}

extrusion_bracket();