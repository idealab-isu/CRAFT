$fn = 64;

// PCB dimensions (mm)
pcb_x  = 35.56;
pcb_y  = 25.4;
pcb_th = 1.6;

module pcb_rect(x, y, th) {
    // Sharp rectangular outline with exact dimensions
    cube([x, y, th], center=false);
}

color([0.05, 0.45, 0.18])
pcb_rect(pcb_x, pcb_y, pcb_th);