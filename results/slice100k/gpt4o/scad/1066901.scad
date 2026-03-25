module bracket() {
    difference() {
        // Main rounded rectangle body
        union() {
            translate([-54, -15.5, 0])
                offset(r=5) 
                    square([108, 31], center=true);
            // Stepped extension
            translate([54, 0, 0])
                offset(r=5)
                    square([20, 31], center=true);
        }
        
        // U-shaped notch
        translate([64, 0, 0])
            difference() {
                offset(r=5)
                    square([20, 31], center=true);
                translate([0, 0, -1])
                    offset(r=5)
                        square([20, 21], center=true);
            }
        
        // 2x3 grid of holes
        for (x = [-30, 0, 30])
            for (y = [-10, 10])
                translate([x, y, 0])
                    cylinder(h=4, r=3, center=true, $fn=64);
        
        // Single smaller hole near rounded end
        translate([-40, 0, 0])
            cylinder(h=4, r=2, center=true, $fn=64);
    }
}

bracket();