module box_section() {
    difference() {
        cube([20, 20, 20], center=true);
        translate([-9, -9, -9])
            cube([18, 18, 22], center=false);
    }
}

box_section();