$fn = 64;

length = 200;
width  = 200;
thickness = 2;

// Ensure a clearly visible, non-zero sheet thickness
t = max(thickness, 2);

cube([length, width, t], center=true);