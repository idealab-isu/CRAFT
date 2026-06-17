$fn = 64;

// Target: Printed circuit board 18.0mm x 18.0mm x 0.8mm (single connected solid)

// Parameters
pcb_L = 18.0;
pcb_W = 18.0;
pcb_T = 0.8;

hole_d = 2.0;
hole_edge_margin = 2.5;

corner_chamfer = 0.6;   // small corner bevel (visual), kept modest
eps = 0.02;             // tiny overlap to guarantee manifold connectivity

// 2D outline with chamfered corners (keeps exact overall L/W)
module pcb_outline_2d(L, W, c) {
    // Clamp chamfer to safe range
    c2 = min(c, min(L, W)/2 - 0.001);

    polygon(points=[
        [ L/2 - c2,  W/2],
        [-L/2 + c2,  W/2],
        [-L/2,  W/2 - c2],
        [-L/2, -W/2 + c2],
        [-L/2 + c2, -W/2],
        [ L/2 - c2, -W/2],
        [ L/2, -W/2 + c2],
        [ L/2,  W/2 - c2]
    ]);
}

// Mounting holes (through the full PCB thickness)
module mounting_holes_3d() {
    hole_h = pcb_T + 2*eps;
    for (x = [-1, 1], y = [-1, 1]) {
        translate([x*(pcb_L/2 - hole_edge_margin), y*(pcb_W/2 - hole_edge_margin), 0])
            cylinder(h=hole_h, r=hole_d/2, center=true);
    }
}

// Final PCB (single solid)
module pcb_final() {
    difference() {
        linear_extrude(height=pcb_T, center=true)
            pcb_outline_2d(pcb_L, pcb_W, corner_chamfer);

        mounting_holes_3d();
    }
}

pcb_final();