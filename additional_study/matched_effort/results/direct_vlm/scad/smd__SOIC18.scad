$fn = 64;

size = [11.40, 7.50, 2.00];

module smd(sz=[11.40,7.50,2.00]) {
    L = sz[0];
    W = sz[1];
    H = sz[2];

    // Feature proportions (kept within overall size)
    pad_t   = min(0.25, H*0.18);          // terminal thickness
    pad_len = min(L*0.18, 2.2);           // terminal length along X
    pad_in  = 0.15;                       // slight inset from ends
    chamfer = min(0.35, H*0.25);          // top edge chamfer
    mark_r  = min(0.55, min(L,W)*0.08);   // polarity mark radius
    mark_d  = min(0.18, H*0.12);          // polarity mark depth

    // Body dimensions (body + pads = overall H)
    bodyH = H - pad_t;

    union() {
        // Main body with top chamfer (single connected solid)
        translate([0, 0, pad_t])
        difference() {
            translate([-L/2, -W/2, 0]) cube([L, W, bodyH], center=false);

            // Chamfer the four top edges by subtracting wedges
            // Along +Y top edge
            translate([-L/2 - 0.01,  W/2 - chamfer, bodyH - chamfer])
                rotate([0, 90, 0])
                    linear_extrude(height=L + 0.02)
                        polygon(points=[[0,0],[chamfer,0],[0,chamfer]]);
            // Along -Y top edge
            translate([-L/2 - 0.01, -W/2, bodyH - chamfer])
                rotate([0, 90, 0])
                    linear_extrude(height=L + 0.02)
                        polygon(points=[[0,0],[chamfer,0],[0,chamfer]]);
            // Along +X top edge
            translate([ L/2 - chamfer, -W/2 - 0.01, bodyH - chamfer])
                rotate([90, 0, 0])
                    linear_extrude(height=W + 0.02)
                        polygon(points=[[0,0],[chamfer,0],[0,chamfer]]);
            // Along -X top edge
            translate([-L/2, -W/2 - 0.01, bodyH - chamfer])
                rotate([90, 0, 0])
                    linear_extrude(height=W + 0.02)
                        polygon(points=[[0,0],[chamfer,0],[0,chamfer]]);

            // Polarity mark: shallow dimple on top near (-X, +Y) corner
            translate([-L/2 + chamfer + mark_r*1.2, W/2 - chamfer - mark_r*1.2, bodyH - mark_d])
                cylinder(h=mark_d + 0.02, r=mark_r, center=false);
        }

        // Terminals/pads (connected to body via overlap)
        overlap = 0.05;

        // Left pad
        translate([-L/2 + pad_in, -W/2, 0])
            cube([pad_len, W, pad_t + overlap], center=false);

        // Right pad
        translate([L/2 - pad_in - pad_len, -W/2, 0])
            cube([pad_len, W, pad_t + overlap], center=false);
    }
}

smd(size);