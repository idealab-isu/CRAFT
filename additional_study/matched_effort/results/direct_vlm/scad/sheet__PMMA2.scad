$fn = 64;

length = 200;
width  = 150;
thickness = 3;

// Ensure a visible, centered, single connected solid (acrylic sheet)
color([0.85, 0.95, 1.0, 0.25])
cube([length, width, thickness], center=true);