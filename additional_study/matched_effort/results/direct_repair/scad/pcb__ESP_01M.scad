$fn = 64;

pcb_x = 18.0;
pcb_y = 18.0;
pcb_th = 0.8;

color([0.05, 0.45, 0.18])
translate([-pcb_x/2, -pcb_y/2, 0])
cube([pcb_x, pcb_y, pcb_th], center=false);