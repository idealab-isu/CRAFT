module swiss_clip() {
    difference() {
        union() {
            // Main body of the clip
            translate([0, 0, -1])
                cube([60, 20, 2], center=true);
            
            // Curved top part
            translate([0, 10, 1])
                rotate([90, 0, 0])
                cylinder(h=20, r=10, center=true, $fn=64);
        }
        
        // Cutout for the clip
        translate([0, 0, 0])
            cube([60, 10, 2], center=true);
    }
}

swiss_clip();