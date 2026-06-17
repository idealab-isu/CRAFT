$fn = 64;

// PCB dimensions (mm)
pcb_x  = 21.0;
pcb_y  = 18.0;
pcb_th = 1.2;

// Rounded edge radius (kept small and valid)
edge_r = 0.6;
edge_r = min(edge_r, min(pcb_x, pcb_y)/2 - 0.01);

module rounded_pcb(x, y, th, r) {
    // One connected solid: rounded rectangle extruded to thickness
    linear_extrude(height = th, center = true, convexity = 10)
        offset(r = r)
            square([x - 2*r, y - 2*r], center = true);
}

color([0.05, 0.45, 0.15])
rounded_pcb(pcb_x, pcb_y, pcb_th, edge_r);