module rounded_plus_sign() {
    difference() {
        // Create the main cross shape
        union() {
            // Central square
            translate([-5.6/2, -5.6/2, 0])
                cube([5.6, 5.6, 5.6]);
            // Horizontal arm
            translate([-26.4/2, -5.6/2, 0])
                cube([26.4, 5.6, 5.6]);
            // Vertical arm
            translate([-5.6/2, -26.4/2, 0])
                cube([5.6, 26.4, 5.6]);
        }
        // Subtract corners to round them
        for (x = [-1, 1])
            for (y = [-1, 1])
                translate([x * (26.4/2 - 5.6), y * (26.4/2 - 5.6), 0])
                    cylinder(r=5.6, h=5.6, $fn=64);
    }
}

translate([0, 0, -5.6/2])
    rounded_plus_sign();