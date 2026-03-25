module bracket() {
    difference() {
        union() {
            // Vertical plate
            cube([0.03, 0.1, 0.1], center=false);
            
            // Horizontal flange with radiused bend
            translate([0, 0, 0.07])
                rotate([90, 0, 0])
                cylinder(h=0.03, r=0.015, $fn=64);
            translate([0.03, 0, 0.07])
                cube([0.03, 0.1, 0.03], center=false);
        }
        
        // Through-holes in vertical plate
        for (x = [0.01, 0.02])
            for (y = [0.02, 0.08])
                translate([x, y, 0.05])
                    cylinder(h=0.1, r=0.0025, $fn=64);
        
        // Slot in horizontal flange
        translate([0.045, 0.05, 0.07])
            cube([0.01, 0.0025, 0.03], center=true);
    }
}

// Create mirrored brackets
translate([-0.075, 0, 0])
    bracket();
translate([0.075, 0, 0])
    mirror([1, 0, 0])
        bracket();