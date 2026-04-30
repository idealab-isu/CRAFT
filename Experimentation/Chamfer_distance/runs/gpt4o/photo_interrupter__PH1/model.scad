translate([-12.95, -3.2, -1.75])
difference() {
    // Base block
    cube([25.9, 6.4, 3.5]);
    
    // Optical gap
    translate([-2.95, -4.3, -1.75])
    cube([5.9, 8.6, 3.5]);
    
    // Mounting hole
    translate([0, 0, -1.75])
    cylinder(h = 3.5, d = 3, $fn = 64);
}