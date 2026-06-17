$fn = 64;

length = 100;
size = 40;
corner_r = 1.5;

color([0.75, 0.78, 0.82])
linear_extrude(height = length)
offset(r = corner_r)
offset(delta = -corner_r)
square([size, size], center = true);