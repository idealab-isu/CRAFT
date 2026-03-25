module octagonal_ring() {
    difference() {
        // Outer octagonal shape
        scale([1, 1, 0.2])
            rotate([0, 0, 22.5])
                cylinder(r=15, h=30, $fn=8);
        
        // Inner circular bore
        translate([0, 0, -1])
            cylinder(r=10, h=8, $fn=64);
        
        // Keyway notches
        translate([-10, 0, -1])
            cube([2, 4, 8], center=true);
        translate([10, 0, -1])
            cube([2, 4, 8], center=true);
    }
}

module pins() {
    // Cylindrical pins
    translate([-12, 0, 3])
        cylinder(r=1, h=3, $fn=64);
    translate([12, 0, 3])
        cylinder(r=1, h=3, $fn=64);
}

translate([0, 0, -3])
    union() {
        octagonal_ring();
        pins();
    }