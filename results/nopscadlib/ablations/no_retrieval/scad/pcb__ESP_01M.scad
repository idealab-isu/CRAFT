// 18.0mm x 18.0mm x 0.8mm PCB (single connected solid)

$fn = 64;

// Parameters (mm)
pcb_L = 18.0;  // length (X)
pcb_W = 18.0;  // width  (Y)
pcb_T = 0.8;   // thickness (Z)

// Small edge chamfer to make thickness visible in renders
chamfer = min(0.25, pcb_T/3, pcb_L/20, pcb_W/20);

module pcb_plate(L, W, T, c) {
    color([0.0, 0.4, 0.2])
    hull() {
        // Four corner posts; hull creates a single connected solid with softened edges
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - c), sy*(W/2 - c), 0])
                cylinder(h=T, r=c, center=true);
    }
}

pcb_plate(pcb_L, pcb_W, pcb_T, chamfer);