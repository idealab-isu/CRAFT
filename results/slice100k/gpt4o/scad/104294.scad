module comb_rack() {
    difference() {
        union() {
            // Main body of the rack
            translate([-12.2, -49.65, -1])
                cube([24.4, 99.3, 2]);

            // Chamfered tip
            translate([-12.2, 47.65, -1])
                rotate([0, 0, 45])
                cube([2.828, 2.828, 2]);

            // Mounting tab
            translate([-12.2, -49.65, -1])
                cube([24.4, 20, 2]);

            // Gear-like cutout
            translate([0, -39.65, 0])
                gear_cutout();

            // Circular through-holes
            translate([-8, -39.65, 0])
                cylinder(h=2, r=2, $fn=64);
            translate([8, -39.65, 0])
                cylinder(h=2, r=2, $fn=64);
        }

        // Rectangular slots/teeth
        for (i = [-10:2:10]) {
            translate([i, 0, -1])
                cube([1, 80, 3]);
        }
    }
}

module gear_cutout() {
    difference() {
        cylinder(h=2, r=6, $fn=64);
        for (i = [0:60:300]) {
            rotate([0, 0, i])
                translate([0, 0, 0])
                cylinder(h=2, r=2, $fn=64);
        }
    }
}

comb_rack();