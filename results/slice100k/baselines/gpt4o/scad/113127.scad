module c_shaped_bracket() {
    difference() {
        // Outer frame
        union() {
            // Main body
            cube([31.8, 31.8, 15.8], center=true);
            
            // Corner bosses
            translate([-15.9, -15.9, 0])
                cube([5, 5, 15.8]);
            translate([10.9, -15.9, 0])
                cube([5, 5, 15.8]);
            translate([-15.9, 10.9, 0])
                cube([5, 5, 15.8]);
            translate([10.9, 10.9, 0])
                cube([5, 5, 15.8]);
        }
        
        // Inner cutout
        translate([-10.9, -10.9, -1])
            cube([21.8, 21.8, 17.8]);
    }
}

c_shaped_bracket();