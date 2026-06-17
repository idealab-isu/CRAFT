$fn = 64;

length = 200;
width  = 200;
thickness = 2;

// Centered sheet so it renders reliably and shows thickness in side views
cube([length, width, thickness], center=true);