module ht_90_pipe() {
    difference() {
        union() {
            cylinder(h=150, r=50, $fn=64);
            translate([0, 0, 150])
                rotate([90, 0, 0])
                cylinder(h=150, r=50, $fn=64);
        }
        translate([0, 0, -1])
            cylinder(h=152, r=45, $fn=64);
    }
}

ht_90_pipe();