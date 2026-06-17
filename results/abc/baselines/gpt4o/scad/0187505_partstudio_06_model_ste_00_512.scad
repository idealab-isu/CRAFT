module plate_with_cutouts() {
    difference() {
        // Base plate
        cube([100, 100, 1], center=true);
        
        // Central pentagonal cutout
        translate([0, 0, -0.5])
            rotate([0, 0, 18])
                cylinder(r1=0, r2=40, h=1.5, $fn=5);
        
        // Corner diamond-oriented square cutouts
        for (x = [-45, 45])
            for (y = [-45, 45])
                translate([x, y, -0.5])
                    rotate([0, 0, 45])
                        square([10, 10], center=true);
    }
}

plate_with_cutouts();