module hex_nut() {
    difference() {
        // Create hexagonal prism
        scale([1, 1, 6.5/2]) 
            cylinder(d=15.0, h=2, $fn=6);
        
        // Subtract the cylindrical hole
        translate([0, 0, -1])
            cylinder(d=8.0, h=8, $fn=64);
    }
}

hex_nut();