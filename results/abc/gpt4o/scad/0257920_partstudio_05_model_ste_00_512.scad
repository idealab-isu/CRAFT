module mounting_block() {
    difference() {
        // Main block
        union() {
            cube([100, 50, 5], center=true);
            // Chamfered corners
            translate([-50, -25, 0])
                rotate([0, 0, 45])
                cube([10, 10, 5], center=true);
            translate([50, -25, 0])
                rotate([0, 0, 45])
                cube([10, 10, 5], center=true);
            translate([-50, 25, 0])
                rotate([0, 0, 45])
                cube([10, 10, 5], center=true);
            translate([50, 25, 0])
                rotate([0, 0, 45])
                cube([10, 10, 5], center=true);
        }
        
        // Diamond apertures
        for (x = [-30, 0, 30]) {
            for (y = [-15, 15]) {
                translate([x, y, 0])
                    rotate([0, 0, 45])
                    square([10, 10], center=true);
            }
        }
        
        // Round holes
        for (x = [-40, 40]) {
            for (y = [-20, 20]) {
                translate([x, y, 0])
                    cylinder(h=10, r=3, center=true, $fn=64);
            }
        }
        
        // Teardrop-like holes
        for (x = [-20, 20]) {
            for (y = [-20, 20]) {
                translate([x, y, 0])
                    union() {
                        translate([0, 2, 0])
                            cylinder(h=10, r=2, center=true, $fn=64);
                        translate([0, -2, 0])
                            scale([1, 0.5, 1])
                            cylinder(h=10, r=2, center=true, $fn=64);
                    }
            }
        }
    }
    
    // Central faceted cylindrical boss
    translate([0, 0, 2.5])
        cylinder(h=10, r=5, center=false, $fn=6);
    
    // Tab/rod-like extensions
    translate([-55, 0, 0])
        cube([10, 5, 5], center=true);
    translate([55, 0, 0])
        cube([10, 5, 5], center=true);
}

mounting_block();