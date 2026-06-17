module radial() {
    for (i = [0 : 5]) {
        rotate([0, 0, i * 60])
        translate([10.5, 0, 0])
        cube([3.7, 3.7, 13.5], center = true);
    }
}

radial();