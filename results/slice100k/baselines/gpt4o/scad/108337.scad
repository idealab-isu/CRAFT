module hexagonal_plate() {
    difference() {
        // Hexagonal plate
        translate([0, 0, -4])
        cylinder(h=8, r=23.1, $fn=6);
        
        // Circular through-hole
        translate([0, 0, -10])
        cylinder(h=20, r=5, $fn=64);
        
        // Step-like thickness changes
        translate([0, 0, -4])
        cylinder(h=2, r=21, $fn=6);
        
        translate([0, 0, -4])
        cylinder(h=4, r=19, $fn=6);
        
        // Diagonal grooves
        translate([-23.1, 0, 3])
        rotate([0, 0, 30])
        cube([46.2, 2, 1]);
        
        translate([-23.1, 0, 5])
        rotate([0, 0, 30])
        cube([46.2, 2, 1]);
    }
}

hexagonal_plate();