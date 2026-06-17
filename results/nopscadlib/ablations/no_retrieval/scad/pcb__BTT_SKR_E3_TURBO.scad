// 3D Printer Mainboard (single connected solid)
// Exact PCB: 102.0mm x 90.25mm x 1.6mm
// No text/labels. All placements are formula-based (no arbitrary offsets).

$fn = 64;

// -------------------- Parameters --------------------
pcb_length = 102.0;
pcb_width  = 90.25;
pcb_thickness = 1.6;

corner_radius = 4.0;

mount_hole_diameter = 3.2;
mount_hole_edge_margin_x = 6.0;
mount_hole_edge_margin_y = 6.0;

connector_height = 10.0;
heatsink_height  = 8.0;
component_height = 3.0;

silkscreen_thickness = 0.2;

// Small overlaps to guarantee watertight unions
z_overlap = 0.25;     // overlap into PCB for top-side parts
side_overlap = 0.6;   // overlap into PCB edge for side connectors
cut_overlap = 0.4;    // overlap for subtractive cuts

// -------------------- Helpers --------------------
module rounded_rect_2d(L, W, R) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R)]) circle(r=R);
    }
}

module pcb_solid() {
    // Exact outer dimensions: L x W x thickness
    linear_extrude(height=pcb_thickness, center=true)
        rounded_rect_2d(pcb_length, pcb_width, corner_radius);
}

module mount_hole(x, y) {
    translate([x, y, 0])
        cylinder(h=pcb_thickness + 2, r=mount_hole_diameter/2, center=true);
}

// Generic top-side block that is guaranteed to touch/overlap the PCB
module top_block(size_xyz, pos_xy) {
    sx = size_xyz[0]; sy = size_xyz[1]; sz = size_xyz[2];
    translate([pos_xy[0], pos_xy[1], pcb_thickness/2 + sz/2 - z_overlap])
        cube([sx, sy, sz], center=true);
}

// Generic bottom-side block (for underside features) that overlaps into PCB
module bottom_block(size_xyz, pos_xy) {
    sx = size_xyz[0]; sy = size_xyz[1]; sz = size_xyz[2];
    translate([pos_xy[0], pos_xy[1], -pcb_thickness/2 - sz/2 + z_overlap])
        cube([sx, sy, sz], center=true);
}

// Generic top-side cylinder that is guaranteed to touch/overlap the PCB
module top_cyl(r, h, pos_xy) {
    translate([pos_xy[0], pos_xy[1], pcb_thickness/2 + h/2 - z_overlap])
        cylinder(r=r, h=h, center=true);
}

// Side connector that protrudes outward from an edge but overlaps into PCB
// edge: "left","right","top","bottom"
module side_connector(edge, size_xyz, offset_along_edge) {
    sx = size_xyz[0]; sy = size_xyz[1]; sz = size_xyz[2];

    if (edge == "left") {
        translate([
            -pcb_length/2 - sx/2 + side_overlap,
            offset_along_edge,
            pcb_thickness/2 + sz/2 - z_overlap
        ]) cube([sx, sy, sz], center=true);
    } else if (edge == "right") {
        translate([
            pcb_length/2 + sx/2 - side_overlap,
            offset_along_edge,
            pcb_thickness/2 + sz/2 - z_overlap
        ]) cube([sx, sy, sz], center=true);
    } else if (edge == "top") {
        translate([
            offset_along_edge,
            pcb_width/2 + sy/2 - side_overlap,
            pcb_thickness/2 + sz/2 - z_overlap
        ]) cube([sx, sy, sz], center=true);
    } else if (edge == "bottom") {
        translate([
            offset_along_edge,
            -pcb_width/2 - sy/2 + side_overlap,
            pcb_thickness/2 + sz/2 - z_overlap
        ]) cube([sx, sy, sz], center=true);
    }
}

// Simple "notch" cut into PCB edge (still one solid overall; subtractive detail)
// edge: "left","right","top","bottom"
module edge_notch(edge, notch_w, notch_d, offset_along_edge) {
    // notch_w: along edge direction, notch_d: depth into board
    // Cut passes through thickness with overlap to ensure clean subtraction.
    if (edge == "left") {
        translate([
            -pcb_length/2 + notch_d/2 + cut_overlap,
            offset_along_edge,
            0
        ]) cube([notch_d + 2*cut_overlap, notch_w, pcb_thickness + 2], center=true);
    } else if (edge == "right") {
        translate([
            pcb_length/2 - notch_d/2 - cut_overlap,
            offset_along_edge,
            0
        ]) cube([notch_d + 2*cut_overlap, notch_w, pcb_thickness + 2], center=true);
    } else if (edge == "top") {
        translate([
            offset_along_edge,
            pcb_width/2 - notch_d/2 - cut_overlap,
            0
        ]) cube([notch_w, notch_d + 2*cut_overlap, pcb_thickness + 2], center=true);
    } else if (edge == "bottom") {
        translate([
            offset_along_edge,
            -pcb_width/2 + notch_d/2 + cut_overlap,
            0
        ]) cube([notch_w, notch_d + 2*cut_overlap, pcb_thickness + 2], center=true);
    }
}

// -------------------- Board with holes + outline details --------------------
module pcb_mainboard() {
    difference() {
        pcb_solid();

        // 4 mounting holes
        mount_hole(-pcb_length/2 + mount_hole_edge_margin_x,  pcb_width/2 - mount_hole_edge_margin_y);
        mount_hole( pcb_length/2 - mount_hole_edge_margin_x,  pcb_width/2 - mount_hole_edge_margin_y);
        mount_hole(-pcb_length/2 + mount_hole_edge_margin_x, -pcb_width/2 + mount_hole_edge_margin_y);
        mount_hole( pcb_length/2 - mount_hole_edge_margin_x, -pcb_width/2 + mount_hole_edge_margin_y);

        // Edge notches to make the outline read as a PCB (non-rectangular details)
        notch_w1 = pcb_width * 0.10;
        notch_d1 = pcb_length * 0.03;
        edge_notch("left",  notch_w1, notch_d1,  pcb_width * 0.28);
        edge_notch("right", notch_w1, notch_d1, -pcb_width * 0.22);

        notch_w2 = pcb_length * 0.12;
        notch_d2 = pcb_width  * 0.03;
        edge_notch("top",    notch_w2, notch_d2, -pcb_length * 0.18);
        edge_notch("bottom", notch_w2, notch_d2,  pcb_length * 0.20);
    }
}

// -------------------- Components (recognizable, connected) --------------------
module connectors() {
    // USB-like connector on left edge (mid-upper)
    usb_w = pcb_length * 0.18;   // along X (protrusion length)
    usb_d = pcb_width  * 0.12;   // along Y
    usb_h = connector_height;
    side_connector("left", [usb_w, usb_d, usb_h], pcb_width * 0.18);

    // Power terminal on right edge (mid-lower)
    pwr_w = pcb_length * 0.22;
    pwr_d = pcb_width  * 0.14;
    pwr_h = connector_height;
    side_connector("right", [pwr_w, pwr_d, pwr_h], -pcb_width * 0.18);

    // Long header along top edge
    hdr_w = pcb_length * 0.55;
    hdr_d = pcb_width  * 0.08;
    hdr_h = connector_height * 0.6;
    side_connector("top", [hdr_w, hdr_d, hdr_h], 0);

    // Bottom-edge connector (e.g., SD/aux)
    aux_w = pcb_length * 0.28;
    aux_d = pcb_width  * 0.10;
    aux_h = connector_height * 0.7;
    side_connector("bottom", [aux_w, aux_d, aux_h], 0);

    // Small JST-like headers on right edge (adds PCB-like silhouette detail)
    jst_w = pcb_length * 0.12;
    jst_d = pcb_width  * 0.07;
    jst_h = connector_height * 0.45;
    for (i = [0:2]) {
        off = (-0.05 + 0.12*i) * pcb_width;
        side_connector("right", [jst_w, jst_d, jst_h], off);
    }
}

module heatsinks() {
    // Two heatsink blocks
    hs1_xy = [-pcb_length*0.18, -pcb_width*0.08];
    hs2_xy = [ pcb_length*0.18,  pcb_width*0.10];

    hs1_sz = [pcb_length*0.20, pcb_width*0.20, heatsink_height];
    hs2_sz = [pcb_length*0.18, pcb_width*0.18, heatsink_height];

    top_block(hs1_sz, hs1_xy);
    top_block(hs2_sz, hs2_xy);

    // Fin ridges on hs1 (connected via overlap)
    fin_count = 7;
    fin_w = hs1_sz[0] * 0.95;
    fin_span = hs1_sz[1] * 0.90;
    fin_d = fin_span / (fin_count*2);
    fin_h = heatsink_height * 0.35;

    for (i = [0:fin_count-1]) {
        y0 = hs1_xy[1] - fin_span/2 + (2*i+1) * fin_d;
        top_block([fin_w, fin_d, fin_h], [hs1_xy[0], y0]);
    }
}

module chips_components() {
    // MCU
    top_block([pcb_length*0.20, pcb_width*0.16, component_height*1.3], [0, 0]);

    // Stepper drivers row (4)
    drv_sz = [pcb_length*0.11, pcb_width*0.11, component_height];
    for (k = [0:3]) {
        x = (-0.27 + 0.18*k) * pcb_length;
        y = pcb_width * 0.24;
        top_block(drv_sz, [x, y]);
    }

    // Inductor / power stage block
    top_block([pcb_length*0.14, pcb_width*0.12, component_height*1.1], [pcb_length*0.28, pcb_width*0.05]);

    // Capacitors (cylinders)
    cap_r = pcb_width * 0.032;
    cap_h = component_height * 1.8;
    top_cyl(cap_r, cap_h, [ pcb_length*0.30, -pcb_width*0.25]);
    top_cyl(cap_r, cap_h, [ pcb_length*0.22, -pcb_width*0.25]);
    top_cyl(cap_r*0.9, cap_h*0.9, [ pcb_length*0.14, -pcb_width*0.25]);

    // Crystal / small can
    top_cyl(pcb_width*0.018, component_height*0.9, [-pcb_length*0.10, -pcb_width*0.02]);

    // SMD clusters
    smd_h = component_height * 0.35;
    smd1 = [pcb_length*0.06, pcb_width*0.03, smd_h];
    smd2 = [pcb_length*0.04, pcb_width*0.02, smd_h];

    for (i = [0:5]) {
        top_block(smd1, [-pcb_length*0.18 + i*(pcb_length*0.035), -pcb_width*0.10]);
        top_block(smd2, [ pcb_length*0.02 + i*(pcb_length*0.028), pcb_width*0.02]);
    }

    // Underside feature (e.g., soldered module footprint) to avoid "thin bars" look in bottom view
    bottom_block([pcb_length*0.55, pcb_width*0.22, component_height*0.55], [0, -pcb_width*0.05]);
}

module silkscreen_layer() {
    // Thin layer on top (kept connected via overlap)
    top_block([pcb_length - 2*corner_radius, pcb_width - 2*corner_radius, silkscreen_thickness], [0, 0]);

    // A few raised "trace-like" ribs to make top view read as PCB (still connected)
    rib_h = silkscreen_thickness * 1.2;
    rib_w = pcb_width * 0.012;
    rib_len1 = pcb_length * 0.70;
    rib_len2 = pcb_length * 0.55;

    top_block([rib_len1, rib_w, rib_h], [0, -pcb_width*0.18]);
    top_block([rib_len2, rib_w, rib_h], [0,  pcb_width*0.12]);
    top_block([pcb_length*0.012, pcb_width*0.55, rib_h], [-pcb_length*0.22, 0]);
}

// -------------------- Final Model (ONE connected solid) --------------------
module complete_model() {
    union() {
        pcb_mainboard();
        connectors();
        heatsinks();
        chips_components();
        silkscreen_layer();
    }
}

color([0.0, 0.4, 0.2])
complete_model();