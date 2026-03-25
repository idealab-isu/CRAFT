module ht_90_pipe() {
    difference() {
        union() {
            // Main pipe
            translate([0, 0, -250])
                cylinder(h=500, r=50, $fn=64);
            // Elbow pipe
            translate([50, 0, 0])
                rotate([0, 90, 0])
                cylinder(h=100, r=50, $fn=64);
        }
        // Inner hollow
        union() {
            translate([0, 0, -250])
                cylinder(h=500, r=45, $fn=64);
            translate([50, 0, 0])
                rotate([0, 90, 0])
                cylinder(h=100, r=45, $fn=64);
        }
    }
}

ht_90_pipe();