module fastener() {
    difference() {
        union() {
            // Cylindrical shank
            translate([0, 0, -11.5])
                cylinder(h=23, d=6.3, $fn=64);
            
            // Circular head
            translate([0, 0, 11.5])
                cylinder(h=3, d=10, $fn=64);
        }
        
        // Longitudinal slot for the split tip
        translate([-3.15, 0, -11.5])
            cube([6.3, 1, 12]);
        
        // Tapered wedge-shaped legs
        translate([0, 0, -11.5])
            rotate([0, 90, 0])
                cylinder(h=6.3, r1=3.15, r2=0, $fn=64);
    }
}

fastener();