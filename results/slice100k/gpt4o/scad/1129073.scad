module spindle() {
    difference() {
        // Outer faceted body
        scale([1, 3.141, 1]) {
            rotate([0, 90, 0]) {
                cylinder(h=7.8, r1=2.25, r2=0, $fn=64);
            }
        }
        // Central slot
        translate([-3.9, -12.25, -2.25]) {
            scale([1, 3.141, 1]) {
                rotate([0, 90, 0]) {
                    cylinder(h=6.8, r=1.5, $fn=64);
                }
            }
        }
        // Side notches
        translate([-3.9, -2, -0.5]) {
            cube([7.8, 4, 1]);
        }
        translate([-3.9, -2, -3.5]) {
            cube([7.8, 4, 1]);
        }
    }
}

translate([0, 0, -2.25]) {
    spindle();
}