$fn = 64;

// Sheet mild steel (modeled as a thin solid plate)
length = 200;   // mm
width  = 120;   // mm
thick  = 2;     // mm

color([0.55, 0.55, 0.58])
cube([length, width, thick], center=true);