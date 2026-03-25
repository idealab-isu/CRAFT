module rounded_rectangle_block() {
    difference() {
        // Main rounded rectangle block
        offset(r=0.01) {
            cube([0.08, 0.08, 0.01], center=true);
        }
        // Recessed pattern on large faces
        translate([0, 0, 0.005])
            offset(r=0.005) {
                cube([0.06, 0.06, 0.001], center=true);
            }
    }
}

module protrusions() {
    for (i = [-0.03, 0, 0.03]) {
        translate([i, 0.04, -0.005])
            cube([0.01, 0.02, 0.005], center=true);
    }
}

translate([0, 0, 0.005])
    union() {
        rounded_rectangle_block();
        protrusions();
    }