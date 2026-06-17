module hexagonal_plate() {
    difference() {
        // Hexagonal plate
        translate([0, 0, -2])
            linear_extrude(height=4)
                polygon(points=[
                    [17.5, 0],
                    [8.75, 15.15],
                    [-8.75, 15.15],
                    [-17.5, 0],
                    [-8.75, -15.15],
                    [8.75, -15.15]
                ]);
        
        // Central hole
        translate([0, 0, -2])
            cylinder(h=8, r=5, $fn=64);
    }
    
    // Raised pad
    translate([0, 0, 1])
        cylinder(h=2, r=10, $fn=64);
}

hexagonal_plate();