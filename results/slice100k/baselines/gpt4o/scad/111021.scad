module rounded_rectangular_housing() {
    difference() {
        // Main rounded rectangular block
        translate([-0.7, -0.5, -1.3])
            minkowski() {
                cube([1.4, 1.0, 2.6 - 0.2]);
                sphere(r=0.1, $fn=64);
            }
        
        // Shallow recessed notch on the opposite face
        translate([-0.6, -0.4, 1.0])
            cube([1.2, 0.8, 0.2]);
    }
}

module latch_boss() {
    // Protruding latch-like boss
    translate([-0.2, 0.5, -0.5])
        cube([0.4, 0.2, 0.6]);
}

module neck_and_tab() {
    // Integral narrow neck
    translate([-0.1, -0.05, -1.5])
        cube([0.2, 0.1, 0.2]);
    
    // Tab/handle with a circular through-hole
    translate([-0.3, -0.3, -1.7])
        difference() {
            cube([0.6, 0.6, 0.2]);
            translate([0, 0, -0.1])
                cylinder(r=0.15, h=0.4, $fn=64);
        }
}

union() {
    rounded_rectangular_housing();
    latch_boss();
    neck_and_tab();
}