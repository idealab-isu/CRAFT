module u_shaped_bracket() {
    difference() {
        // Main U-shaped body
        union() {
            // Rounded back
            translate([0, 0, 39.5])
                rotate([90, 0, 0])
                cylinder(h=22.1, r=12.15, $fn=64);
            // Side walls
            translate([-11.05, -12.15, 0])
                cube([22.1, 24.3, 79.0]);
        }
        // Internal channel
        translate([-9.05, -10.15, 0])
            cube([18.1, 20.3, 79.0]);
    }
    
    // Internal cylindrical bosses/holes
    module internal_boss(x, z) {
        translate([x, 0, z])
            rotate([90, 0, 0])
            cylinder(h=24.3, r=2.5, $fn=64);
    }
    
    // Add bosses/holes
    internal_boss(-9.05, 10);
    internal_boss(9.05, 10);
    internal_boss(-9.05, 69);
    internal_boss(9.05, 69);
    
    // Front-edge tabs/lips
    module front_tab(x) {
        translate([x, -12.15, 0])
            cube([2, 24.3, 2]);
    }
    
    // Add tabs/lips
    front_tab(-11.05);
    front_tab(9.05);
}

u_shaped_bracket();