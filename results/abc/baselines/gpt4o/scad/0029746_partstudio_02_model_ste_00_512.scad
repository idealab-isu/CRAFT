module rail_beam() {
    difference() {
        // Main beam
        translate([-100, -0.5, -5])
        cube([200, 1, 10]);

        // Central elongated rounded-rectangle slot
        translate([-50, -0.25, -5.5])
        hull() {
            translate([0, 0, 0])
            cylinder(h=11, r=1, $fn=64);
            translate([100, 0, 0])
            cylinder(h=11, r=1, $fn=64);
        }

        // Four diamond-shaped through-holes
        for (x = [-80, 80]) {
            for (y = [-0.25, 0.25]) {
                translate([x, y, -5.5])
                rotate([0, 0, 45])
                square([2, 2]);
            }
        }

        // Tapered/triangular web with lightening cutouts
        for (x = [-90, 90]) {
            translate([x, -0.5, -5])
            rotate([0, 0, 45])
            difference() {
                square([20, 20]);
                translate([2, 2])
                square([16, 16]);
            }
        }

        // Small central diamond cutout
        translate([-1, -0.5, -5])
        rotate([0, 0, 45])
        square([2, 2]);
    }
}

rail_beam();