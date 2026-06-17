$fn = 64;

size = 20.0;      // mm
length = 100.0;   // mm

linear_extrude(height = length, center = false, convexity = 10)
    square([size, size], center = false);