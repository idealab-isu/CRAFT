$fn = 64;

// PCB dimensions (mm)
pcb_x  = 18.0;
pcb_y  = 18.0;
pcb_th = 0.8;

// Small edge rounding (keeps one connected solid and preserves overall size)
edge_r = 0.25; // mm

// Ensure rounding does not exceed half the smallest dimension
edge_r_eff = min(edge_r, pcb_x/2, pcb_y/2, pcb_th/2);

minkowski() {
    // Base block reduced so Minkowski restores exact overall dimensions
    cube([pcb_x - 2*edge_r_eff, pcb_y - 2*edge_r_eff, pcb_th - 2*edge_r_eff], center=true);
    sphere(r=edge_r_eff);
}