module diamond_cutout(size, thickness) {
    rotate([0, 0, 45])
    scale([1, 0.5, 1])
    cube([size, size, thickness], center=true);
}

module circular_disk_with_features() {
    difference() {
        // Main disk
        union() {
            cylinder(h=5, r=20, $fn=64);
            translate([0, 0, 2.5])
                cube([10, 10, 5], center=true);
        }
        // Recessed rim
        translate([0, 0, 0.5])
            cylinder(h=4, r=18, $fn=64);
        // Diamond cutouts
        translate([0, 15, 2.5])
            diamond_cutout(5, 5);
        translate([15, 0, 2.5])
            diamond_cutout(5, 5);
        translate([-15, 0, 2.5])
            diamond_cutout(5, 5);
        translate([0, -15, 2.5])
            diamond_cutout(5, 5);
        translate([0, 0, 2.5])
            diamond_cutout(5, 5);
    }
}

module square_peg() {
    translate([0, 0, -5])
        cube([10, 10, 5], center=true);
}

translate([0, 0, 2.5])
    union() {
        circular_disk_with_features();
        square_peg();
    }