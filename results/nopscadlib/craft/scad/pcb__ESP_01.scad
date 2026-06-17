// PCB: 24.8mm x 14.6mm x 1.0mm (single connected solid)

pcb_length    = 24.8;
pcb_width     = 14.6;
pcb_thickness = 1.0;

// Small rounding helps visibility in renders while keeping exact overall size.
corner_radius = 0.25; // mm (set to 0 for sharp corners)

$fn = 96;

module pcb_board(L, W, T, R) {
    // Guard against invalid radii that could create empty geometry
    r = max(0, min(R, min(L, W)/2 - 0.001));

    if (r <= 0) {
        cube([L, W, T], center=true);
    } else {
        // Rounded rectangle in XY, extruded to thickness T.
        // offset(r=r) applied to a reduced square keeps overall size exactly L x W.
        linear_extrude(height=T, center=true, convexity=10)
            offset(r=r)
                square([L - 2*r, W - 2*r], center=true);
    }
}

color([0.0, 0.4, 0.2])
    pcb_board(pcb_length, pcb_width, pcb_thickness, corner_radius);