module washer_body() {
    difference() {
        cylinder(h = 1.6, d = 17.0);
        translate([0, 0, -0.1]) // Slightly lower to ensure clean subtraction
            cylinder(h = 1.8, d = 8.0);
    }
}

washer_body();