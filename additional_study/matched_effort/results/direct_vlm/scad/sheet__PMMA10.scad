$fn = 64;

length = 200;
width  = 200;
thickness = 2;

// Ensure a clearly visible, non-zero sheet thickness
min_th = 2;
th = max(thickness, min_th);

// One connected solid: a single sheet
cube([length, width, th], center=true);