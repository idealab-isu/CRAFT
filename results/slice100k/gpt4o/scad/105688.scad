module split_cylindrical_sleeve() {
    difference() {
        // Main cylinder
        cylinder(h=78.5, r=9.45, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(h=80.5, r=6.45, $fn=64);
        
        // Axial slit
        translate([-9.75, -9.75, -1])
            cube([19.5, 5, 80.5]);
        
        // Internal relief notches
        for (i = [-1, 1]) {
            translate([i * 7.5, 0, 20])
                rotate([0, 90, 0])
                    cylinder(h=5, r=1.5, $fn=32);
            translate([i * 7.5, 0, 40])
                rotate([0, 90, 0])
                    cylinder(h=5, r=1.5, $fn=32);
            translate([i * 7.5, 0, 60])
                rotate([0, 90, 0])
                    cylinder(h=5, r=1.5, $fn=32);
        }
    }
}

split_cylindrical_sleeve();