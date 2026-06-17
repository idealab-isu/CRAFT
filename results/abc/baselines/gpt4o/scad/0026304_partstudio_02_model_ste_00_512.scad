module rod_component() {
    union() {
        // Main ribbed cylindrical midsection
        translate([0, 0, -0.5])
        ribbed_cylinder(0.3, 0.9, 0.05, 0.02, 10);

        // Polygonal end caps
        translate([0, 0, -0.7])
        polygonal_end_cap(0.3, 0.2, 6);
        
        translate([0, 0, 0.7])
        polygonal_end_cap(0.3, 0.2, 6);

        // Radial tabs/protrusions
        for (i = [-0.4, -0.2, 0, 0.2, 0.4]) {
            translate([0, 0, i])
            radial_tab(0.35, 0.05, 0.02);
        }

        // Single side nub
        translate([0.35, 0, -0.6])
        nub(0.05, 0.02);
    }
}

module ribbed_cylinder(d, h, rib_height, rib_spacing, rib_count) {
    difference() {
        cylinder(d = d, h = h, $fn = 64);
        for (i = [0 : rib_spacing : h]) {
            translate([0, 0, i])
            cylinder(d = d + rib_height, h = rib_height, $fn = 64);
        }
    }
}

module polygonal_end_cap(d, h, sides) {
    rotate([90, 0, 0])
    cylinder(d = d, h = h, $fn = sides);
}

module radial_tab(d, w, h) {
    translate([-w/2, -d/2, -h/2])
    cube([w, d, h]);
}

module nub(d, h) {
    translate([-d/2, -d/2, 0])
    cylinder(d = d, h = h, $fn = 32);
}

rod_component();