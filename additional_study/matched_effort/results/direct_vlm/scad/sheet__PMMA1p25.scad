$fn = 64;

// Sheet acrylic
length = 200;
width  = 150;
thickness = 3;

// Slight tint + transparency to read as acrylic in preview/renders
acrylic_rgba = [0.75, 0.90, 1.00, 0.25];

color(acrylic_rgba)
    cube([length, width, thickness], center=true);