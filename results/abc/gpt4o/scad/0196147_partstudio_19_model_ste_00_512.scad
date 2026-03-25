module hex_nut() {
    difference() {
        // Hexagonal prism
        scale([1, 1, 0.5])
            cylinder(r=10, h=10, $fn=6);
        
        // Central circular through-hole
        translate([0, 0, -5])
            cylinder(r=5, h=20, $fn=64);
    }
    
    // Chamfer top and bottom edges
    for (z = [-5, 5]) {
        translate([0, 0, z])
            rotate([0, 0, 30])
                scale([1, 1, 0.1])
                    cylinder(r=10, h=10, $fn=6);
    }
}

hex_nut();