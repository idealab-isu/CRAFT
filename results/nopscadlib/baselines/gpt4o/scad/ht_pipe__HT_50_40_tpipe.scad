module ht_pipe() {
    $fn = 64;
    // Main vertical pipe
    cylinder(h = 100, r1 = 25, r2 = 25, center = true);
    
    // Horizontal pipe
    translate([0, 0, 25])
    rotate([90, 0, 0])
    cylinder(h = 100, r1 = 20, r2 = 20, center = true);
}

ht_pipe();