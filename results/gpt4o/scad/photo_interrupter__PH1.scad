module photo_interrupter() {
    difference() {
        union() {
            // Base block
            translate([-15, -10, 0])
            cube([30, 20, 5]);

            // Left arm
            translate([-15, -5, 5])
            cube([5, 10, 20]);

            // Right arm
            translate([10, -5, 5])
            cube([5, 10, 20]);
        }

        // Slot for interruption
        translate([-5, -5, 5])
        cube([10, 10, 20]);
    }
}

photo_interrupter();