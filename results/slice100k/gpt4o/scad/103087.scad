module chamfered_bar() {
    difference() {
        // Main rectangular bar
        cube([16.6, 55.0, 20.1], center=true);
        
        // Chamfers on the corners
        for (x_shift = [-8.3, 8.3]) {
            for (y_shift = [-27.5, 27.5]) {
                translate([x_shift, y_shift, 0])
                    rotate([0, 45, 0])
                    cube([16.6, 5, 20.1], center=true);
            }
        }
    }
}

module hex_hole_with_countersink() {
    union() {
        // Hexagonal through-hole
        translate([0, 0, -10.05])
            rotate([90, 0, 0])
            cylinder(h=20.1, r=5, $fn=6, center=true);
        
        // V-shaped countersink
        for (z_shift = [-10.05, 10.05]) {
            translate([0, 0, z_shift])
                rotate([90, 0, 0])
                cylinder(h=2, r1=7, r2=5, $fn=64, center=true);
        }
    }
}

difference() {
    chamfered_bar();
    translate([0, 0, 0])
        hex_hole_with_countersink();
}