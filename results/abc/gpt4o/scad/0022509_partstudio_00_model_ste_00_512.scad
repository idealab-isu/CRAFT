module tray_housing() {
    difference() {
        // Outer shape with chamfered sides and overhanging flange
        union() {
            // Main body
            translate([-50, -25, 0])
                scale([1, 1, 0.5])
                    cube([100, 50, 20], center=false);
            // Overhanging flange
            translate([-52, -27, 10])
                cube([104, 54, 2], center=false);
        }
        // Recessed central panel
        translate([-45, -20, 0])
            cube([90, 40, 10], center=false);
        // Long narrow slot
        translate([-20, -2, 0])
            cube([40, 4, 10], center=false);
    }
}

tray_housing();