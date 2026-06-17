$fn = 64;

// Target board: 67.0mm x 31.0mm x 1.7mm (ONE connected solid)
board_L = 67.0;
board_W = 31.0;
board_T = 1.7;

// Visual/feature params
corner_chamfer = 0.6;          // small corner chamfer (visual)
hole_d = 3.2;
hole_edge_margin = 4.0;

copper_T = 0.08;               // slightly thicker so it renders reliably
silk_T  = 0.08;

boss_d = 6.0;                  // small bosses around holes to keep model one solid
boss_h = 0.6;

conn_L = 16.0;                 // connector blocks (visual)
conn_W = 14.0;
conn_H = 3.0;

comp_L = 24.0;                 // component block (visual)
comp_W = 16.0;
comp_H = 4.0;

overlap = 0.25;                // overlap to guarantee connectivity

module pcb_base_chamfered() {
    // Chamfered rectangle via 2D offset then linear_extrude
    linear_extrude(height = board_T, center = true)
        offset(delta = -corner_chamfer)
            offset(delta = corner_chamfer)
                square([board_L, board_W], center = true);
}

module hole_bosses() {
    // Add bosses (not holes) so the model remains ONE connected solid
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(board_L/2 - hole_edge_margin),
                   sy*(board_W/2 - hole_edge_margin),
                   board_T/2 + boss_h/2 - overlap])
            cylinder(h = boss_h, r = boss_d/2, center = true);
    }
}

module copper_patches() {
    // Two copper rectangles on top face, positioned to resemble reference views
    // Left patch
    translate([-board_L/2 + (board_L*0.34)/2 + hole_edge_margin*0.2,
               0,
               board_T/2 + copper_T/2 - overlap])
        cube([board_L*0.34, board_W*0.32, copper_T], center = true);

    // Right patch
    translate([ board_L/2 - (board_L*0.34)/2 - hole_edge_margin*0.2,
               0,
               board_T/2 + copper_T/2 - overlap])
        cube([board_L*0.34, board_W*0.32, copper_T], center = true);
}

module silkscreen_plate() {
    translate([0, 0, board_T/2 + silk_T/2 - overlap])
        cube([board_L - 2*hole_edge_margin,
              board_W - 2*hole_edge_margin,
              silk_T], center = true);
}

module connector_blocks() {
    // Two connector-like blocks on opposite ends, connected to top face
    translate([ board_L/2 - conn_L/2 - hole_edge_margin*0.3,
                0,
                board_T/2 + conn_H/2 - overlap])
        cube([conn_L, conn_W, conn_H], center = true);

    translate([-board_L/2 + conn_L/2 + hole_edge_margin*0.3,
                0,
                board_T/2 + conn_H/2 - overlap])
        cube([conn_L, conn_W, conn_H], center = true);
}

module component_block() {
    // Central-ish component block, connected to top face
    translate([0,
               0,
               board_T/2 + comp_H/2 - overlap])
        cube([comp_L, comp_W, comp_H], center = true);
}

union() {
    color([0.0, 0.4, 0.2]) pcb_base_chamfered();

    // Keep everything as one connected solid by overlapping into the PCB
    color([0.1, 0.2, 0.6]) hole_bosses();
    color([0.72, 0.45, 0.2]) copper_patches();
    color("White") silkscreen_plate();
    color([0.85, 0.85, 0.8]) connector_blocks();
    color([0.85, 0.85, 0.8]) component_block();
}