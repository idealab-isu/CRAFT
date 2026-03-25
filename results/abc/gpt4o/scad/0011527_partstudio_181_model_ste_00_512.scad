module flange() {
    difference() {
        // Main disk
        cylinder(h=5, r=50, $fn=64);
        
        // Central large hole
        translate([0, 0, -1])
            cylinder(h=7, r=20, $fn=64);
        
        // Small hexagonal holes
        for (i = [0:7]) {
            rotate([0, 0, i * 45])
                translate([35, 0, -1])
                    cylinder(h=7, r=3, $fn=6);
        }
    }
}

flange();