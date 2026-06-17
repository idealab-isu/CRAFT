$fn = 64;

length = 200;
width  = 200;
thickness = 2;

// Ensure a visible, non-zero thickness
t = max(thickness, 0.5);

// Single connected solid: a simple sheet
cube([length, width, t], center=true);