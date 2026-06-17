module v_shaped_strip() {
    difference() {
        // Main body of the strip
        cube([61.0, 12.8, 5.1], center=true);
        
        // Create the V-shaped profile
        translate([0, 0, -2.55])
        rotate([0, 90, 0])
        cylinder(h=61.0, r1=0, r2=2.55, $fn=64);
        
        // Create the end steps/shoulders
        translate([-30.5, 0, -2.55])
        cube([5.0, 12.8, 2.55], center=false);
        
        translate([25.5, 0, -2.55])
        cube([5.0, 12.8, 2.55], center=false);
        
        // Create the mid-length seam/transition
        translate([-2.5, 0, -2.55])
        cube([5.0, 12.8, 0.5], center=false);
    }
}

v_shaped_strip();