$fn = 64;

// Aluminium tooling plate (sheet)
length = 300;   // mm
width  = 200;   // mm
thick  = 6;     // mm

color([0.75, 0.78, 0.82])
cube([length, width, thick], center=false);