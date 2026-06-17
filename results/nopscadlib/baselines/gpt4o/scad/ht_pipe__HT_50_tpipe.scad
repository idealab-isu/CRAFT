module ht_pipe() {
    difference() {
        union() {
            // Main vertical pipe
            translate([0, 0, -25])
                cylinder(h=50, r=25, $fn=64);
            // Horizontal pipe
            translate([-25, -25, 0])
                rotate([90, 0, 0])
                cylinder(h=50, r=25, $fn=64);
        }
        // Inner cut for vertical pipe
        translate([0, 0, -25])
            cylinder(h=50, r=20, $fn=64);
        // Inner cut for horizontal pipe
        translate([-25, -25, 0])
            rotate([90, 0, 0])
            cylinder(h=50, r=20, $fn=64);
    }
}

ht_pipe();