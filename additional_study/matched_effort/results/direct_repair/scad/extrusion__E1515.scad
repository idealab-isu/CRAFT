$fn = 64;

length = 100;
size = 15;

linear_extrude(height = length)
    square([size, size], center = true);