$fn = 64;

// Parameters
pcb_length = 67.0; //[33.5:134.0:0.5]
pcb_width = 31.0;  //[15.5:62.0:0.5]
pcb_thickness = 1.7; //[0.85:3.4:0.1]

silkscreen_thickness = 0.05; //[0.02:0.2:0.01]
copper_thickness = 0.035; //[0.017:0.105:0.001]
layer_inset = 0.5; //[0.25:2.0:0.25]
overlap = 0.5; //[0.2:2.0:0.1]

hole_radius = 1.5; //[0.75:3.0:0.25]

connector_block_length = 10.0; //[5.0:20.0:0.5]
connector_block_width  = 8.0;  //[4.0:16.0:0.5]
connector_block_height = 6.0;  //[3.0:12.0:0.5]

component_block_size = 6.0; //[3.0:12.0:0.5]

// Derived
board_z0 = -pcb_thickness/2;
board_z1 =  pcb_thickness/2;

// PCB Board with mounting holes (holes are cut out)
module pcb_board_with_holes() {
    hole_edge_inset = max(hole_radius + 1.5, 3.5);
    hx = pcb_length/2 - hole_edge_inset;
    hy = pcb_width/2  - hole_edge_inset;

    color([0.0, 0.4, 0.2])
    difference() {
        cube([pcb_length, pcb_width, pcb_thickness], center=true);

        // 4 mounting holes
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*hx, sy*hy, 0])
                cylinder(h=pcb_thickness + 2*overlap, r=hole_radius, center=true);
    }
}

// Silkscreen layer (thin raised sheet)
module silkscreen_markings() {
    color("White")
    translate([0, 0, board_z1 + silkscreen_thickness/2 - overlap])
        cube([pcb_length - 2*layer_inset, pcb_width - 2*layer_inset, silkscreen_thickness], center=true);
}

// Copper layer (thin raised sheet)
module copper_pads() {
    color([0.72, 0.45, 0.2])
    translate([0, 0, board_z1 + copper_thickness/2 - overlap])
        cube([pcb_length - 2*layer_inset, pcb_width - 2*layer_inset, copper_thickness], center=true);
}

// Simple terminal connector block on one short edge
module connectors() {
    // Place so it sits on top of PCB and touches the +Y edge
    zc = board_z1 + connector_block_height/2 - overlap;
    yc = pcb_width/2 - connector_block_width/2 + overlap;

    color([0.15, 0.15, 0.15])
    translate([0, yc, zc])
        cube([connector_block_length, connector_block_width, connector_block_height], center=true);

    // Small "pins" as bumps to suggest terminals (still connected)
    pin_r = 0.8;
    pin_h = 2.0;
    pin_zc = board_z1 + connector_block_height + pin_h/2 - overlap;
    for (i = [-1, 0, 1]) {
        translate([i*(connector_block_length/4), yc, pin_zc])
            cylinder(h=pin_h, r=pin_r, center=true);
    }
}

// A few generic components (blocks/cylinders) on top, all connected
module components() {
    // IC block
    ic_l = 16;
    ic_w = 10;
    ic_h = 3.0;
    ic_zc = board_z1 + ic_h/2 - overlap;
    ic_xc = -pcb_length/2 + ic_l/2 + 8;
    ic_yc = -pcb_width/2 + ic_w/2 + 7;

    color([0.08, 0.08, 0.08])
    translate([ic_xc, ic_yc, ic_zc])
        cube([ic_l, ic_w, ic_h], center=true);

    // Inductor (cylinder)
    ind_r = 5.5;
    ind_h = 4.5;
    ind_zc = board_z1 + ind_h/2 - overlap;
    ind_xc = pcb_length/2 - ind_r - 10;
    ind_yc = -pcb_width/2 + ind_r + 8;

    color([0.2, 0.2, 0.2])
    translate([ind_xc, ind_yc, ind_zc])
        cylinder(h=ind_h, r=ind_r, center=true);

    // Capacitor (cylinder)
    cap_r = 4.0;
    cap_h = 8.0;
    cap_zc = board_z1 + cap_h/2 - overlap;
    cap_xc = pcb_length/2 - cap_r - 8;
    cap_yc = pcb_width/2 - connector_block_width - cap_r - 4;

    color([0.05, 0.05, 0.05])
    translate([cap_xc, cap_yc, cap_zc])
        cylinder(h=cap_h, r=cap_r, center=true);

    // Small component blocks (resistors/regulators)
    sm_h = 2.2;
    sm_zc = board_z1 + sm_h/2 - overlap;
    sm_l = component_block_size;
    sm_w = component_block_size/2;

    color([0.25, 0.25, 0.25])
    for (k = [0:3]) {
        x = -pcb_length/2 + 18 + k*(sm_l + 2);
        y = 0;
        translate([x, y, sm_zc])
            cube([sm_l, sm_w, sm_h], center=true);
    }
}

// Complete PCB Model (ONE connected solid via overlaps)
module pcb_complete_model() {
    union() {
        pcb_board_with_holes();
        silkscreen_markings();
        copper_pads();
        connectors();
        components();
    }
}

// Final Output
pcb_complete_model();