module thick_walled_ring() {
    difference() {
        // Outer cylinder
        cylinder(h=115, d=45, $fn=64);
        
        // Inner bore
        translate([0, 0, -1])
            cylinder(h=117, d=35, $fn=64);
        
        // Rectangular cutouts
        for (i = [0, 90, 180, 270]) {
            rotate([0, 0, i])
                translate([22.5, -5, 0])
                    cube([10, 10, 115]);
        }
    }
}

translate([0, 0, -57.5])
    thick_walled_ring();