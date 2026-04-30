$fn=64;

module nema17_mount() {
    difference() {
        // Base plate
        cube([60, 60, 3], center=true);
        
        // Center bore
        translate([0, 0, -1.5])
            cylinder(h=5, d=22, center=true);
        
        // Mounting holes
        for (x = [-15.5, 15.5])
            for (y = [-15.5, 15.5])
                translate([x, y, -1.5])
                    cylinder(h=5, d=3, center=true);
    }
}

nema17_mount();