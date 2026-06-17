// PCB: 21.0mm x 18.0mm x 1.2mm (single connected solid)
$fn = 64;

pcb_L = 21.0;
pcb_W = 18.0;
pcb_T = 1.2;

// Small corner radius to look like a real PCB while keeping exact outer dimensions
corner_r = 1.0;

module rounded_rect_prism(L, W, T, r) {
    linear_extrude(height = T, center = true)
        offset(r = r)
            square([L - 2*r, W - 2*r], center = true);
}

color([0.0, 0.4, 0.2])
rounded_rect_prism(pcb_L, pcb_W, pcb_T, corner_r);