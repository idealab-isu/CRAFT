module u_shaped_bracket() {
    difference() {
        // Main U-shaped body
        union() {
            // Outer rounded back
            translate([0, 0, 39.5])
                rotate([90, 0, 0])
                cylinder(h=22.1, r=12.15, $fn=64);
            
            // Side walls
            translate([-11.05, -12.15, 0])
                cube([22.1, 24.3, 79.0]);
        }
        
        // Inner channel
        translate([-9.05, -10.15, 0])
            cube([18.1, 20.3, 79.0]);
        
        // Fillets on outer perimeter
        translate([-11.05, -12.15, 0])
            offset(r=2)
            cube([22.1, 24.3, 79.0]);
    }
    
    // Circular through-holes on side walls
    translate([-11.05, 0, 39.5])
        rotate([90, 0, 0])
        cylinder(h=24.3, r=2.5, $fn=64);
    
    translate([11.05, 0, 39.5])
        rotate([90, 0, 0])
        cylinder(h=24.3, r=2.5, $fn=64);
    
    // Top-front corner tabs/lips
    translate([-11.05, -12.15, 76])
        cube([22.1, 2, 3]);
}

u_shaped_bracket();