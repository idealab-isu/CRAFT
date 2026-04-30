module servo_bracket() {
    difference() {
        // Main body of the bracket
        union() {
            // Base plate
            translate([-12.5, -10, 0])
                cube([25, 20, 2]);

            // Side walls
            translate([-12.5, -10, 2])
                cube([2, 20, 15]);
            translate([10.5, -10, 2])
                cube([2, 20, 15]);

            // Top plate
            translate([-12.5, -10, 17])
                cube([25, 20, 2]);
        }

        // Servo slot
        translate([-10, -8, 0])
            cube([20, 16, 17]);

        // Horn slot
        translate([-2.5, -1, 17])
            cube([5, 2, 2]);
    }
}

servo_bracket();