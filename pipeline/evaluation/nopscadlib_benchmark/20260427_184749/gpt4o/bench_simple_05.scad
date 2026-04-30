$fn=64;

module lm8uu_holder() {
    difference() {
        // Outer block
        cube([30, 30, 20], center=true);
        
        // Hole for the bearing
        translate([0, 0, -10])
            cylinder(h=20, d=15, center=true);
    }
}

lm8uu_holder();