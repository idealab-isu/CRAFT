module frame_with_hook() {
    difference() {
        // Outer frame
        union() {
            // Main rectangular frame
            translate([-50, -50, 0])
                cube([100, 100, 1]);
            // Thicker end block
            translate([-50, 40, 0])
                cube([100, 10, 1]);
        }
        // Central rectangular through-opening
        translate([-40, -40, -1])
            cube([80, 80, 3]);
    }
    
    // Stepped, angled cantilever tab
    translate([20, 0, 0]) {
        rotate([0, 0, 45]) {
            translate([-5, -5, 0])
                cube([10, 20, 1]);
        }
    }
}

frame_with_hook();