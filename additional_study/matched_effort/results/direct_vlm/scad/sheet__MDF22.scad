$fn = 64;

sheet_length = 600;   // mm
sheet_width  = 400;   // mm
sheet_thick  = 6;     // mm

color([0.78, 0.67, 0.50])
cube([sheet_length, sheet_width, sheet_thick], center=true);