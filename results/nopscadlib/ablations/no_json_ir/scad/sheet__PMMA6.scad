// Parameters
sheet_length = 100;
sheet_width  = 50;
sheet_thickness = 2;

$fn = 64;

// Ensure non-zero, visible geometry
L = max(sheet_length, 0.01);
W = max(sheet_width,  0.01);
T = max(sheet_thickness, 0.01);

// One connected solid: a simple rectangular sheet
cube([L, W, T], center=true);