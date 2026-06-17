module rounded_rectangle_plate() {
    difference() {
        // Main body with rounded corners
        hull() {
            translate([-2.7, -0.3, 0])
                circle(r=0.3, $fn=64);
            translate([2.7, -0.3, 0])
                circle(r=0.3, $fn=64);
            translate([-2.7, 0.3, 0])
                circle(r=0.3, $fn=64);
            translate([2.7, 0.3, 0])
                circle(r=0.3, $fn=64);
        }
        // Scallops on the sides
        translate([-2.7, 0, 0])
            cylinder(h=6.7, r=0.15, $fn=64);
        translate([2.7, 0, 0])
            cylinder(h=6.7, r=0.15, $fn=64);
    }
}

module surface_contour() {
    // Diagonal rib-like relief
    for (i = [-2.5:0.5:2.5]) {
        translate([i, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=0.05, r1=0.1, r2=0.05, $fn=64);
    }
}

module plate_with_contour() {
    union() {
        rounded_rectangle_plate();
        surface_contour();
    }
}

translate([0, 0, -3.35])
    plate_with_contour();