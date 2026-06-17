$fn = 64;

// LCD 1602A display module (approx) 71.3mm x 24.3mm
// Simple renderable model: PCB + bezel + glass window + 4 mounting holes

module lcd1602a_module(
    pcb_x = 71.3,
    pcb_y = 24.3,
    pcb_t = 1.6,

    hole_d = 3.2,
    hole_edge_x = 2.5,   // distance from left/right edge to hole center
    hole_edge_y = 2.0,   // distance from bottom/top edge to hole center

    bezel_x = 64.0,
    bezel_y = 16.0,
    bezel_t = 3.0,
    bezel_z = 1.6,       // sits on top of PCB

    window_x = 56.0,
    window_y = 12.0,
    window_t = 1.2,
    window_inset = 0.8   // inset from bezel top
) {
    // PCB with mounting holes
    difference() {
        color([0.05, 0.35, 0.12])
            translate([-pcb_x/2, -pcb_y/2, 0])
                cube([pcb_x, pcb_y, pcb_t], center=false);

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_x/2 - hole_edge_x), sy*(pcb_y/2 - hole_edge_y), -0.1])
                cylinder(d=hole_d, h=pcb_t + 0.2);
        }
    }

    // Bezel/frame on top of PCB
    color([0.08, 0.08, 0.08])
        translate([-bezel_x/2, -bezel_y/2, bezel_z])
            cube([bezel_x, bezel_y, bezel_t], center=false);

    // Glass window on top of bezel
    color([0.2, 0.45, 0.55, 0.55])
        translate([-window_x/2, -window_y/2, bezel_z + bezel_t - window_t - window_inset])
            cube([window_x, window_y, window_t], center=false);
}

lcd1602a_module();