module hollow_cylindrical_ring() {
    difference() {
        // Outer cylinder
        cylinder(h=82.5, r=11, $fn=64);
        // Inner cylinder (bore)
        translate([0, 0, -1])
            cylinder(h=84.5, r=9.5, $fn=64);
    }
}

module rectangular_lug() {
    translate([11, -9.5, 41.25])
        cube([3, 19, 10], center=false);
}

translate([0, 0, -41.25])
    union() {
        hollow_cylindrical_ring();
        rectangular_lug();
    }