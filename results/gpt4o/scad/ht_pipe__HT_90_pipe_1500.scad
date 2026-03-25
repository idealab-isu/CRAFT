module ht_pipe() {
    difference() {
        union() {
            // Horizontal pipe
            translate([-750, 0, 0])
                cylinder(h=1500, r=50, $fn=64);
            // Vertical pipe
            translate([0, 0, -750])
                rotate([90, 0, 0])
                cylinder(h=1500, r=50, $fn=64);
        }
        // Inner horizontal pipe
        translate([-750, 0, 0])
            cylinder(h=1500, r=45, $fn=64);
        // Inner vertical pipe
        translate([0, 0, -750])
            rotate([90, 0, 0])
            cylinder(h=1500, r=45, $fn=64);
    }
}

ht_pipe();