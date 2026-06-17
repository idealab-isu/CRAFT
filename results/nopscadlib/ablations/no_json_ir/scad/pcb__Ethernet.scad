$fn = 64;

// =====================
// Target overall PCB size
// =====================
pcb_w = 33.8;
pcb_l = 37.5;
pcb_t = 1.6;

// Corner ears (small round protrusions)
ear_r = 2.2;
ear_inset = 0.6;

// Mounting holes (through PCB)
hole_r = 1.5;
hole_edge_clear = 2.6; // from OUTERMOST outline (incl. ears) to hole center

// Connectivity overlap (ensures one connected solid)
z_overlap = 0.25;
xy_overlap = 0.25;

// =====================
// Component sizes (simple but board-like)
// =====================
conn_wall = 1.2;

// Top-side parts
heatsink_h = 3.0; heatsink = [12, 12, heatsink_h];
ic_h = 2.0;       ic1 = [10, 10, ic_h]; ic2 = [8, 6, ic_h];
header_h = 4.0;   header = [18, 6, header_h];
usb_h = 5.0;      usb = [10, 8, usb_h];
side_conn_h = 6.0; side_conn = [6, 10, side_conn_h];

// Bottom-side parts
pad_h = 0.6; pad = [10, 6, pad_h];
driver_h = 2.2; driver = [9, 9, driver_h];

// =====================
// Helpers
// =====================
module pcb_outline_2d() {
    union() {
        square([pcb_w, pcb_l], center=true);

        ex = pcb_w/2 + ear_r - ear_inset;
        ey = pcb_l/2 + ear_r - ear_inset;

        translate([ ex,  ey]) circle(r=ear_r);
        translate([-ex,  ey]) circle(r=ear_r);
        translate([ ex, -ey]) circle(r=ear_r);
        translate([-ex, -ey]) circle(r=ear_r);
    }
}

module pcb_solid() {
    linear_extrude(height=pcb_t, center=true)
        pcb_outline_2d();
}

module mounting_holes_cut() {
    outer_w = pcb_w + 2*(ear_r - ear_inset);
    outer_l = pcb_l + 2*(ear_r - ear_inset);

    hx = outer_w/2 - hole_edge_clear;
    hy = outer_l/2 - hole_edge_clear;

    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*hx, sy*hy, 0])
            cylinder(h=pcb_t + 1.0, r=hole_r, center=true);
}

module connector_block(size_xyz, pos_xy, z0, hollow=false) {
    // z0 is bottom Z of the part; overlap into PCB handled by caller via z0
    sx = size_xyz[0]; sy = size_xyz[1]; sz = size_xyz[2];
    translate([pos_xy[0], pos_xy[1], z0 + sz/2])
        if (!hollow)
            cube([sx, sy, sz], center=true);
        else
            difference() {
                cube([sx, sy, sz], center=true);
                // inner cavity (kept conservative to avoid negative sizes)
                inner_x = max(0.1, sx - 2*conn_wall);
                inner_y = max(0.1, sy - 2*conn_wall);
                inner_z = max(0.1, sz - conn_wall);
                translate([0, 0, conn_wall/2])
                    cube([inner_x, inner_y, inner_z], center=true);
            }
}

module edge_header_pins(num=8, pitch=2.54, pin=[0.8, 0.8, 3.0], pos_xy=[0,0], z0=0) {
    // Simple pin row to make the board look like a controller; all pins connected via z0 overlap
    total = (num-1)*pitch;
    for (i=[0:num-1]) {
        x = pos_xy[0] - total/2 + i*pitch;
        connector_block(pin, [x, pos_xy[1]], z0, hollow=false);
    }
}

module components() {
    top_z0 = pcb_t/2 - z_overlap;
    bot_z0 = -pcb_t/2 - 0.01 + z_overlap; // bottom parts overlap upward into PCB

    // --- TOP SIDE ---
    // Central heatsink-ish block
    connector_block(heatsink, [0, 0], top_z0, hollow=false);

    // Two ICs
    connector_block(ic1, [-6, 8], top_z0, hollow=false);
    connector_block(ic2, [ 8, 10], top_z0, hollow=false);

    // Long header near +Y edge (kept inside outline by formula)
    header_y = pcb_l/2 - header[1]/2 - xy_overlap;
    connector_block(header, [0, header_y], top_z0, hollow=false);

    // USB-like connector near -Y edge (hollow)
    usb_y = -pcb_l/2 + usb[1]/2 + xy_overlap;
    connector_block(usb, [0, usb_y], top_z0, hollow=true);

    // Side connectors near +/-X edges (hollow), positioned from board edges by formulas
    side_x = pcb_w/2 - side_conn[0]/2 - xy_overlap;
    connector_block(side_conn, [ side_x, 0], top_z0, hollow=true);
    connector_block(side_conn, [-side_x, 0], top_z0, hollow=true);

    // Pin row near -Y edge (adds recognizable header detail)
    pins_y = -pcb_l/2 + 2.54 + xy_overlap;
    edge_header_pins(num=10, pitch=2.54, pin=[0.8, 0.8, 3.2], pos_xy=[0, pins_y], z0=top_z0);

    // --- BOTTOM SIDE ---
    // Bottom pad block
    connector_block(pad, [0, -6], bot_z0 - pad_h, hollow=false);

    // Two driver-ish blocks on bottom to make orthographic side views non-identical
    dx = pcb_w/4;
    dy = pcb_l/6;
    connector_block(driver, [ dx, dy], bot_z0 - driver_h, hollow=false);
    connector_block(driver, [-dx, dy], bot_z0 - driver_h, hollow=false);
}

module pcb_control_board() {
    union() {
        difference() {
            pcb_solid();
            mounting_holes_cut();
        }
        components();
    }
}

pcb_control_board();