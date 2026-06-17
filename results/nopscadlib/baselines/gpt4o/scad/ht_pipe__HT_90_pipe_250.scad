module ht_90_pipe() {
    difference() {
        union() {
            // Main pipe
            cylinder(h=250, r=50, $fn=64);
            // Elbow pipe
            translate([0, 50, 200])
                rotate([90, 0, 0])
                cylinder(h=100, r=50, $fn=64);
        }
        // Inner hollow
        union() {
            // Main pipe hollow
            translate([0, 0, 5])
                cylinder(h=240, r=45, $fn=64);
            // Elbow pipe hollow
            translate([0, 50, 205])
                rotate([90, 0, 0])
                cylinder(h=90, r=45, $fn=64);
        }
    }
}

ht_90_pipe();