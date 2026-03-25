module starburst() {
    // Main long bar
    translate([-18.85, -2.5, -2.5])
        cube([37.7, 5, 5]);

    // Shorter spokes
    for (i = [0:5]) {
        rotate([0, 0, i * 60])
            translate([-10, -2.5, -2.5])
                cube([20, 5, 5]);
    }
}

translate([0, 0, -2.5])
    starburst();