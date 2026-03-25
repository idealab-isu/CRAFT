module tag() {
    difference() {
        union() {
            // Main plate with chamfered ends
            translate([-50, -10, 0])
            hull() {
                translate([0, 0, 0]) square([100, 20], center = true);
                translate([0, 0, 0]) circle(10, $fn=64);
            }
            
            // Circular boss at one end
            translate([50, 0, 0])
            cylinder(h=2, r=10, $fn=64);
        }
        
        // Diamond-shaped through-hole
        translate([50, 0, -1])
        rotate(45)
        scale([1, 0.5, 1])
        square([10, 10], center = true);
    }
    
    // Embossed lettering "ASTRID"
    translate([-30, -5, 0.1])
    linear_extrude(height=1)
    text("ASTRID", size=5, valign="center", halign="center");

    // Small geometric logo
    translate([40, -5, 0.1])
    linear_extrude(height=1)
    polygon(points=[[0,0], [5,0], [2.5,5]]);
}

tag();