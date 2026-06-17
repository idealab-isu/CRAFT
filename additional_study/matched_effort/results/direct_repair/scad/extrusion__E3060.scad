$fn = 64;

// Parameters
length = 100;          // mm
w = 60;                // mm (X)
h = 30;                // mm (Y)

// Simple representation of a 30x60 aluminum extrusion as a solid bar
cube([w, h, length], center = false);