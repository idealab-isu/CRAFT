$fn = 64;

// =====================
// Mainboard dimensions (VERIFIABLE)
// =====================
L = 102.0;      // X overall
W = 90.25;      // Y overall
T = 1.6;        // Z PCB thickness (uniform)

// Corner rounding
corner_r = 3.0;

// Mounting holes
hole_d = 3.0;
hole_off_x = 5.0;
hole_off_y = 5.0;

// Small overlap to guarantee one connected solid
ov = 0.25;

// =====================
// Helpers
// =====================
module rounded_rect_2d(l, w, r) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)])
                circle(r=r);
    }
}

// 2D outline that matches the "stepped" mainboard silhouette in the renders
module board_outline_2d() {
    // Step sizes derived from overall dimensions (no arbitrary placement)
    tab_w = L * 0.18;     // width of top/bottom tabs along X
    tab_h = W * 0.08;     // height of top/bottom tabs along Y
    side_w = L * 0.10;    // width of side tabs along X
    side_h = W * 0.12;    // height of side tabs along Y

    union() {
        rounded_rect_2d(L, W, corner_r);

        // Top tabs (two)
        for (sx = [-1, 1])
            translate([sx*(L*0.22),  W/2 + tab_h/2 - ov])
                square([tab_w, tab_h], center=true);

        // Bottom tabs (two)
        for (sx = [-1, 1])
            translate([sx*(L*0.18), -W/2 - tab_h/2 + ov])
                square([tab_w, tab_h], center=true);

        // Right side tabs (two)
        for (sy = [-1, 1])
            translate([ L/2 + side_w/2 - ov, sy*(W*0.18)])
                square([side_w, side_h], center=true);

        // Left side tabs (two)
        for (sy = [-1, 1])
            translate([-L/2 - side_w/2 + ov, sy*(W*0.12)])
                square([side_w, side_h], center=true);
    }
}

module pcb() {
    difference() {
        // Uniform 1.6mm PCB thickness
        linear_extrude(height=T)
            board_outline_2d();

        // Mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - hole_off_x), sy*(W/2 - hole_off_y), -1])
                cylinder(h=T+2, d=hole_d);

        // Two small semicircular notches (as seen in renders), cut into PCB edge
        notch_d = 6.0;
        notch_in = 1.2; // how far the notch center is inside the board edge
        // Right edge pair
        for (yy = [W*0.18, W*0.12])
            translate([L/2 - notch_in, yy, -1])
                cylinder(h=T+2, d=notch_d);
        // Bottom edge pair
        for (xx = [L*0.10, L*0.16])
            translate([xx, -W/2 + notch_in, -1])
                cylinder(h=T+2, d=notch_d);
    }
}

// Generic component that sits on top of PCB and overlaps slightly into it
module top_component(size=[10,10,5], pos=[0,0], zlift=0) {
    translate([pos[0], pos[1], T - ov + zlift])
        cube([size[0], size[1], size[2]], center=false);
}

// Edge connector that protrudes outward from PCB edge but remains connected
// edge: "right","left","top","bottom"
module edge_connector(edge="right", body=[18,12,10], inset=2.0, y=0, x=0) {
    // body = [len_along_edge, depth_outward, height]
    if (edge == "right") {
        // Connected by overlapping into PCB by inset
        translate([ L/2 - inset, y - body[0]/2, T - ov])
            cube([body[1] + inset, body[0], body[2]], center=false);
    } else if (edge == "left") {
        translate([-L/2 - body[1], y - body[0]/2, T - ov])
            cube([body[1] + inset, body[0], body[2]], center=false);
    } else if (edge == "top") {
        translate([ x - body[0]/2,  W/2 - inset, T - ov])
            cube([body[0], body[1] + inset, body[2]], center=false);
    } else if (edge == "bottom") {
        translate([ x - body[0]/2, -W/2 - body[1], T - ov])
            cube([body[0], body[1] + inset, body[2]], center=false);
    }
}

// Simple pin header block on top of PCB
module pin_header(pos=[0,0], pins=8, pitch=2.54, body_h=6.0) {
    body_l = pins * pitch + 2.0;
    body_w = 6.0;
    top_component([body_l, body_w, body_h], [pos[0]-body_l/2, pos[1]-body_w/2]);
}

// Stepper driver socket (raised block)
module driver_socket(pos=[0,0]) {
    top_component([18, 15, 8], [pos[0]-9, pos[1]-7.5]);
}

// MCU / main IC
module mcu(pos=[0,0]) {
    top_component([22, 22, 3.0], [pos[0]-11, pos[1]-11]);
}

// Capacitor (cylinder) on top, overlapped into PCB
module capacitor(pos=[0,0], d=8, h=12) {
    translate([pos[0], pos[1], T - ov])
        cylinder(d=d, h=h);
}

// Heatsink block on top
module heatsink(pos=[0,0]) {
    top_component([16, 16, 10], [pos[0]-8, pos[1]-8]);
}

// =====================
// Assembly (ONE connected solid)
// =====================
module mainboard_assembly() {
    union() {
        pcb();

        // Right edge: USB + SD-like connectors (protrude outward, connected via inset overlap)
        edge_connector("right", body=[16, 14, 11], inset=2.0, y= W*0.25);
        edge_connector("right", body=[14, 12,  8], inset=2.0, y=-W*0.20);

        // Left edge: auxiliary connector block
        edge_connector("left",  body=[18, 12,  9], inset=2.0, y= 0);

        // Top edge: power terminal + headers
        edge_connector("top",   body=[18, 10, 12], inset=2.0, x=-L*0.20);
        edge_connector("top",   body=[26,  8,  8], inset=2.0, x= L*0.20);

        // Bottom edge: motor connectors row
        edge_connector("bottom", body=[30, 8, 9], inset=2.0, x=0);

        // On-board components (all sit on top of PCB; no bottom extrusions)
        mcu([ -L*0.10,  0 ]);
        heatsink([ L*0.18, W*0.10 ]);

        // Stepper driver sockets (typical row)
        driver_socket([ -L*0.25, -W*0.20 ]);
        driver_socket([ -L*0.05, -W*0.20 ]);
        driver_socket([  L*0.15, -W*0.20 ]);

        // Pin headers
        pin_header([ -L*0.30,  W*0.25 ], pins=10);
        pin_header([  L*0.05,  W*0.30 ], pins=8);

        // Capacitors near power area
        capacitor([ -L*0.22,  W*0.38 ], d=10, h=14);
        capacitor([ -L*0.10,  W*0.38 ], d=8,  h=12);

        // Small ICs / passives as low blocks
        top_component([10, 8, 2.5], [ L*0.05 - 5,  W*0.05 - 4 ]);
        top_component([12, 6, 2.0], [ L*0.28 - 6, -W*0.02 - 3 ]);
        top_component([14,10, 2.5], [ -L*0.35 - 7,  W*0.05 - 5 ]);
    }
}

mainboard_assembly();