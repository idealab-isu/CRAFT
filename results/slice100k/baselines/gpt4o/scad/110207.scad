module stepped_cylindrical_sleeve() {
    difference() {
        union() {
            // Main body
            cylinder(h=12, d1=27.2, d2=27.2, $fn=64);
            
            // First step
            translate([0, 0, 2])
                cylinder(h=2, d1=25, d2=25, $fn=64);
            
            // Second step
            translate([0, 0, 4])
                cylinder(h=2, d1=23, d2=23, $fn=64);
            
            // Third step
            translate([0, 0, 6])
                cylinder(h=2, d1=21, d2=21, $fn=64);
            
            // Fourth step
            translate([0, 0, 8])
                cylinder(h=2, d1=23, d2=23, $fn=64);
            
            // Fifth step
            translate([0, 0, 10])
                cylinder(h=2, d1=25, d2=25, $fn=64);
        }
        
        // Recessed bands
        translate([0, 0, 3])
            cylinder(h=1, d1=20, d2=20, $fn=64);
        
        translate([0, 0, 9])
            cylinder(h=1, d1=20, d2=20, $fn=64);
    }
}

stepped_cylindrical_sleeve();