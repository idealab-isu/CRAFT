$fn = 64;

// Single-board computer / PCB
// Target: 51.0mm x 21.0mm x 1.6mm (ONE connected solid)

// ---------------- Parameters ----------------
pcb_length    = 51.0;
pcb_width     = 21.0;
pcb_thickness = 1.6;

// Rounded corners
corner_round_r = 1.2;

// Mounting holes
mount_hole_diameter      = 2.7;
mount_hole_edge_offset_x = 3.5;
mount_hole_edge_offset_y = 3.5;
hole_cut_extra           = 0.8;

// Raised silkscreen (kept connected)
silkscreen_thickness = 0.2;
silkscreen_margin    = 1.5;

// Connectivity overlap (use 1–2mm as requested)
overlap_xy = 1.2;   // side-to-side overlap into PCB outline
overlap_z  = 1.2;   // vertical overlap into PCB thickness (clamped where needed)

// Components (simple recognizable SBC features)
connR_len = 14;
connR_w   = 8;
connR_h   = 5;

connT_len = 10;
connT_w   = 6;
connT_h   = 4;

connB1_len = 12;
connB1_w   = 8;
connB1_h   = 4;

connB2_len = 16;
connB2_w   = 9;
connB2_h   = 4;

ic_len = 10;
ic_w   = 10;
ic_h   = 1.6;

hdr_len = pcb_length - 2*silkscreen_margin;
hdr_w   = 2.0;
hdr_h   = 1.2;

// ---------------- Helpers ----------------
module rounded_rect_2d(L, W, r) {
    // Guard against impossible radii
    rr = min(r, (min(L, W) / 2) - 0.01);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - rr), sy*(W/2 - rr)]) circle(r=rr);
    }
}

module pcb_body() {
    // Simple rectangular PCB plate (51 x 21 x 1.6)
    linear_extrude(height=pcb_thickness, center=true)
        rounded_rect_2d(pcb_length, pcb_width, corner_round_r);
}

module mounting_holes_cut() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([ sx*(pcb_length/2 - mount_hole_edge_offset_x),
                    sy*(pcb_width/2  - mount_hole_edge_offset_y),
                    0 ])
            cylinder(h=pcb_thickness + hole_cut_extra,
                     r=mount_hole_diameter/2,
                     center=true);
    }
}

// ---------------- Additive details (kept small; do NOT change PCB outline) ----------------
module silkscreen() {
    // Raised on top face, slightly overlapping into PCB for connectivity
    z_ov = min(overlap_z, pcb_thickness*0.9);
    translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - z_ov])
        cube([pcb_length - 2*silkscreen_margin,
              pcb_width  - 2*silkscreen_margin,
              silkscreen_thickness], center=true);
}

module top_components() {
    z_ov = min(overlap_z, pcb_thickness*0.9);

    // Right-side connector (protrudes +X, overlaps into PCB in X and Z)
    translate([ pcb_length/2 + connR_len/2 - overlap_xy,
                0,
                pcb_thickness/2 + connR_h/2 - z_ov ])
        cube([connR_len, connR_w, connR_h], center=true);

    // Top-edge connector (protrudes +Y, overlaps into PCB in Y and Z)
    translate([ 0,
                pcb_width/2 + connT_w/2 - overlap_xy,
                pcb_thickness/2 + connT_h/2 - z_ov ])
        cube([connT_len, connT_w, connT_h], center=true);

    // IC near center (on top, overlaps into PCB in Z)
    translate([ -pcb_length*0.10,
                pcb_width*0.10,
                pcb_thickness/2 + ic_h/2 - z_ov ])
        cube([ic_len, ic_w, ic_h], center=true);

    // Header strip near top edge (on top, overlaps into PCB in Z)
    translate([ 0,
                pcb_width/2 - (silkscreen_margin + hdr_w/2),
                pcb_thickness/2 + hdr_h/2 - z_ov ])
        cube([hdr_len, hdr_w, hdr_h], center=true);
}

module bottom_components() {
    z_ov = min(overlap_z, pcb_thickness*0.9);

    // Underside connector near left (protrudes -X, overlaps into PCB in X and Z)
    translate([ -pcb_length/2 - connB2_len/2 + overlap_xy,
                -pcb_width*0.15,
                -pcb_thickness/2 - connB2_h/2 + z_ov ])
        cube([connB2_len, connB2_w, connB2_h], center=true);

    // Underside connector near bottom edge (protrudes -Y, overlaps into PCB in Y and Z)
    translate([ 0,
                -pcb_width/2 - connB1_w/2 + overlap_xy,
                -pcb_thickness/2 - connB1_h/2 + z_ov ])
        cube([connB1_len, connB1_w, connB1_h], center=true);
}

// ---------------- Complete model (ONE connected solid) ----------------
module complete_model() {
    union() {
        // PCB plate with mounting holes (still reads as a simple 51x21x1.6 board)
        difference() {
            pcb_body();
            mounting_holes_cut();
        }

        // Additive details (kept as small features on/under the PCB)
        silkscreen();
        top_components();
        bottom_components();
    }
}

complete_model();