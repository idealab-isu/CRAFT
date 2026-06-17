$fn = 64;

// Target dimensions (verified by construction)
pcb_L = 37.5;   // Y
pcb_W = 33.8;   // X
pcb_T = 1.6;    // Z
corner_r = 2.0;

// Connectivity overlap (small, consistent)
overlap = 0.25;

// Feature sizes (kept modest so PCB thickness reads correctly)
silk_T   = 0.05;
copper_T = 0.035;

// Central "main IC / module" block (gray)
ic_L = 14.0;   // X
ic_W = 14.0;   // Y
ic_H = 3.0;    // Z

// Edge connectors/ports (black), placed on different edges like reference views
top_conn_L = 14.0;  // X
top_conn_W = 7.0;   // Y (depth into board)
top_conn_H = 3.0;   // Z

bot_conn_L = 16.0;  // X
bot_conn_W = 7.0;   // Y
bot_conn_H = 3.0;   // Z

side_conn_L = 7.0;  // X (depth into board)
side_conn_W = 12.0; // Y
side_conn_H = 3.0;  // Z

// Mounting holes (cut through PCB) - keep inside rounded corners
mh_r = 1.6;
mh_edge = 4.0; // distance from outer edges to hole centers

// ---------- Helpers ----------
module rounded_rect_2d(w, l, r) {
    // 2D rounded rectangle centered at origin
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r), sy*(l/2 - r)]) circle(r=r);
    }
}

module pcb_solid() {
    // PCB with real mounting holes (difference keeps it one connected solid)
    difference() {
        color([0.0, 0.4, 0.2])
            linear_extrude(height=pcb_T, center=true)
                rounded_rect_2d(pcb_W, pcb_L, corner_r);

        // Mounting holes: 4 corners, through thickness
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_W/2 - mh_edge), sy*(pcb_L/2 - mh_edge), 0])
                cylinder(r=mh_r, h=pcb_T + 2, center=true);
        }
    }
}

module silkscreen() {
    // Thin top layer, slightly inset, overlapped into PCB
    color("White")
    translate([0, 0, pcb_T/2 + silk_T/2 - overlap])
        linear_extrude(height=silk_T, center=true)
            rounded_rect_2d(pcb_W - 2*1.2, pcb_L - 2*1.2, max(0.5, corner_r-0.6));
}

module copper_pads() {
    // Simple pads on top, overlapped into PCB
    color([0.72, 0.45, 0.2])
    translate([0, 0, pcb_T/2 + copper_T/2 - overlap])
        union() {
            pad_L = 10;
            pad_W = 6;
            offx = 7;
            offy = 8;
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*offx, sy*offy, 0])
                    cube([pad_L, pad_W, copper_T], center=true);
        }
}

module central_module() {
    // Gray block centered (matches reference square)
    color([0.65, 0.65, 0.68])
    translate([0, 0, pcb_T/2 + ic_H/2 - overlap])
        cube([ic_L, ic_W, ic_H], center=true);
}

module edge_connectors() {
    color([0.12, 0.12, 0.14])
    union() {
        // Top edge connector (front view: black at top)
        translate([0,
                   pcb_L/2 - top_conn_W/2 + overlap,
                   pcb_T/2 + top_conn_H/2 - overlap])
            cube([top_conn_L, top_conn_W, top_conn_H], center=true);

        // Bottom edge connector (back view: black at bottom)
        translate([0,
                   -(pcb_L/2 - bot_conn_W/2 + overlap),
                   pcb_T/2 + bot_conn_H/2 - overlap])
            cube([bot_conn_L, bot_conn_W, bot_conn_H], center=true);

        // Right edge connector (left view: black on right)
        translate([pcb_W/2 - side_conn_L/2 + overlap,
                   0,
                   pcb_T/2 + side_conn_H/2 - overlap])
            cube([side_conn_L, side_conn_W, side_conn_H], center=true);

        // Left edge connector (right view: black on left)
        translate([-(pcb_W/2 - side_conn_L/2 + overlap),
                   0,
                   pcb_T/2 + side_conn_H/2 - overlap])
            cube([side_conn_L, side_conn_W, side_conn_H], center=true);
    }
}

// ---------- Complete connected model ----------
union() {
    pcb_solid();
    silkscreen();
    copper_pads();
    central_module();
    edge_connectors();
}