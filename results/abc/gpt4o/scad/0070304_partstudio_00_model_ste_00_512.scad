module hex_hole(size, height) {
    rotate([0, 0, 90])
    cylinder(r=size, h=height, $fn=6);
}

module stepped_mounting_plate() {
    difference() {
        union() {
            // Main rectangular body
            translate([-50, -25, 0])
            cube([100, 50, 5]);
            
            // Narrower tongue with rounded tip
            translate([-25, -12.5, 0])
            union() {
                cube([50, 25, 5]);
                translate([25, 0, 0])
                rotate([0, 90, 0])
                cylinder(r=12.5, h=25, $fn=64);
            }
        }
        
        // Larger hex hole on the rectangular section
        translate([0, 0, -1])
        hex_hole(5, 7);
        
        // Four smaller hex holes in a 2x2 pattern near the rounded end
        for (x = [-10, 10])
            for (y = [-5, 5])
                translate([x, y + 25, -1])
                hex_hole(2.5, 7);
    }
}

stepped_mounting_plate();