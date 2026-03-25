module hex_prismatic_block() {
    difference() {
        // Hexagonal prism
        rotate([0, 0, 90])
        cylinder(h=46.2, r=20, $fn=6);
        
        // Circular through-hole
        translate([0, 0, -5])
        cylinder(h=60, r=2, $fn=64);
        
        // Diagonal recessed band/groove
        translate([-23.1, -20, 3.5])
        rotate([0, 0, 45])
        cube([46.2, 5, 1]);
        
        // End chamfers/steps
        translate([-23.1, -20, 0])
        cube([46.2, 40, 1]);
        translate([-23.1, -20, 6])
        cube([46.2, 40, 1]);
        
        // Notch-like relief
        translate([20, -20, 0])
        cube([6.2, 40, 7]);
    }
}

translate([0, 0, -3.5])
hex_prismatic_block();