module beveled_cuboid() {
    difference() {
        cube([0.8, 0.8, 1.2], center=true);
        translate([-0.4, -0.4, -0.6])
            cube([0.8, 0.8, 1.2], center=true);
    }
}

beveled_cuboid();