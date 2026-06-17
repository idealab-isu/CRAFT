$fn = 64;

length = 100;
width  = 100;
thickness = 1;

// Robust, non-zero thickness for reliable rendering/printing
min_t = 0.5;
t = max(thickness, min_t);

cube([length, width, t], center=true);