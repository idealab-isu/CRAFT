$fn = 64;

pcb_length = 40.0;
pcb_width  = 16.0;
pcb_thick  = 1.6;

color([0.05, 0.45, 0.18])
translate([-pcb_length/2, -pcb_width/2, 0])
cube([pcb_length, pcb_width, pcb_thick], center=false);