module annular_ring() {
    difference() {
        // Outer cylinder
        cylinder(h=11.8, r=30.3, $fn=64);
        
        // Inner cylinder (large central opening)
        translate([0, 0, -1])
            cylinder(h=13.8, r=20, $fn=64);
        
        // Rectangular notches on the inner diameter
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
                translate([15, -2.5, -1])
                    cube([5, 5, 13.8]);
        }
    }
}

module external_tabs() {
    union() {
        // First tab
        translate([30.3, 0, 0])
            cube([5, 5, 11.8]);
        
        // Second tab
        translate([30.3, 5, 0])
            cube([5, 5, 11.8]);
    }
}

translate([0, 0, -5.9])
    union() {
        annular_ring();
        external_tabs();
    }