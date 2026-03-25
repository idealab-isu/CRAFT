module hex_nut() {
    difference() {
        // Hexagonal prism
        scale([1, 1, 0.5])
            cylinder(r=10, h=10, $fn=6);
        
        // Circular through-hole
        translate([0, 0, -5])
            cylinder(r=5, h=20, $fn=64);
    }
}

module chamfered_hex_nut() {
    union() {
        hex_nut();
        
        // Chamfer edges
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
                translate([8.66, 0, 0]) // 8.66 is the distance from center to edge of hexagon
                    rotate([90, 0, 0])
                        cylinder(r1=0, r2=2, h=2, $fn=64);
        }
    }
}

chamfered_hex_nut();