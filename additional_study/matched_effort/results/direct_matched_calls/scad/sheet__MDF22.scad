$fn = 64;

length = 600;   // mm
width  = 400;   // mm
thick  = 6;     // mm (MDF sheet thickness)

color([0.78, 0.67, 0.50])
cube([length, width, thick], center=false);