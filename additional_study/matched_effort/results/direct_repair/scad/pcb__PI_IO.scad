$fn = 64;

pcb_length = 35.56;   // mm
pcb_width  = 25.4;    // mm
pcb_thick  = 1.6;     // mm

color([0.05, 0.45, 0.18])
cube([pcb_length, pcb_width, pcb_thick], center=false);