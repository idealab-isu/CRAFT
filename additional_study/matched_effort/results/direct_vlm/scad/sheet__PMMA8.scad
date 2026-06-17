$fn = 64;

// Units: inches
thickness = 5/16;   // 0.3125"
width     = 6;
length    = 6;

// Single connected solid, centered at origin for reliable orthographic visibility
cube([length, width, thickness], center=true);