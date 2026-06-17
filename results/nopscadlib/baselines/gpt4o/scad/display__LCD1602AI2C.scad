module lcd_display() {
    difference() {
        // Main body of the display
        translate([-71.3/2, -24.3/2, 0])
            cube([71.3, 24.3, 10]);

        // Cutout for the screen
        translate([-61.3/2, -14.3/2, 0.1])
            cube([61.3, 14.3, 10.1]);
    }
}

lcd_display();