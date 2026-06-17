$fn = 64;

//====================
// Parameters (mm)
//====================
pcb_L = 80.4;
pcb_W = 36.3;
pcb_T = 1.5;

overlap = 0.8;                 // intentional interpenetration to guarantee one connected solid
hole_d = 3.2;
hole_edge_margin = 4.5;

edge_chamfer_size = 1.2;

// Component heights (above PCB)
connector_H = 10;
connector_depth = 8;
connector_len = 18;

chip_T = 2;
chip1_L = 14;
chip1_W = 14;

chip2_L = 10;
chip2_W = 8;

heatsink_L = 16;
heatsink_W = 16;
heatsink_H = 8;

// Extra components to better match reference views
small1_L = chip2_L*0.6;
small1_W = chip2_W*0.5;
small1_T = chip_T*0.7;

small2_L = chip2_L*0.5;
small2_W = chip2_W*0.4;
small2_T = chip_T*0.6;

// Bottom-side components (to match bottom view)
bottom_chip_L = 12;
bottom_chip_W = 10;
bottom_chip_T = 2.2;

bottom_small_L = 8;
bottom_small_W = 5;
bottom_small_T = 1.6;

//====================
// Helpers
//====================
module pcb_mainboard_body() {
  color([0.0, 0.4, 0.2])
    cube([pcb_L, pcb_W, pcb_T], center=true);
}

module mounting_hole_cyl() {
  // Cut through PCB (and a bit extra) so holes are visible and guaranteed to subtract
  cylinder(h=pcb_T + 2*overlap, r=hole_d/2, center=true);
}

module edge_chamfer_cut_corner() {
  // Simple corner nibble (not a true chamfer, but matches simplified look)
  cube([edge_chamfer_size, edge_chamfer_size, pcb_T + 2*overlap], center=true);
}

module connector_body(L, D, H) {
  color([0.85, 0.85, 0.8])
    cube([L, D, H], center=true);
}

module chip_body(L, W, T) {
  color([0.1, 0.1, 0.6])
    cube([L, W, T], center=true);
}

module heatsink_body() {
  color([0.75, 0.75, 0.77])
    cube([heatsink_L, heatsink_W, heatsink_H], center=true);
}

//====================
// PCB with holes + corner cuts
//====================
module pcb_with_holes_and_chamfers() {
  difference() {
    pcb_mainboard_body();

    // Mounting holes
    union() {
      translate([-pcb_L/2 + hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0]) mounting_hole_cyl();
      translate([ pcb_L/2 - hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0]) mounting_hole_cyl();
      translate([-pcb_L/2 + hole_edge_margin,  pcb_W/2 - hole_edge_margin, 0]) mounting_hole_cyl();
      translate([ pcb_L/2 - hole_edge_margin,  pcb_W/2 - hole_edge_margin, 0]) mounting_hole_cyl();
    }

    // Corner nibbles
    union() {
      translate([ pcb_L/2 - edge_chamfer_size/2,  pcb_W/2 - edge_chamfer_size/2, 0]) edge_chamfer_cut_corner();
      translate([-pcb_L/2 + edge_chamfer_size/2,  pcb_W/2 - edge_chamfer_size/2, 0]) edge_chamfer_cut_corner();
      translate([-pcb_L/2 + edge_chamfer_size/2, -pcb_W/2 + edge_chamfer_size/2, 0]) edge_chamfer_cut_corner();
      translate([ pcb_L/2 - edge_chamfer_size/2, -pcb_W/2 + edge_chamfer_size/2, 0]) edge_chamfer_cut_corner();
    }
  }
}

//====================
// Top-side components (z+)
//====================
module top_side_components() {
  union() {
    // Left connector (front view: left side)
    translate([
      -pcb_L/2 + connector_len/2 - overlap,
      0,
      pcb_T/2 + connector_H/2 - overlap
    ]) connector_body(connector_len, connector_depth, connector_H);

    // Right connector (front view: bottom-right area)
    translate([
      pcb_L/2 - (connector_len*0.8)/2 + overlap,
      -pcb_W/2 + (connector_depth*0.9)/2 - overlap,
      pcb_T/2 + (connector_H*0.8)/2 - overlap
    ]) connector_body(connector_len*0.8, connector_depth*0.9, connector_H*0.8);

    // Main chip (center)
    translate([0, 0, pcb_T/2 + chip_T/2 - overlap])
      chip_body(chip1_L, chip1_W, chip_T);

    // Secondary chip (upper-left quadrant)
    translate([-pcb_L*0.2, pcb_W*0.2, pcb_T/2 + chip_T/2 - overlap])
      chip_body(chip2_L, chip2_W, chip_T);

    // Small components (right side)
    translate([pcb_L*0.25, pcb_W*0.15, pcb_T/2 + small1_T/2 - overlap])
      chip_body(small1_L, small1_W, small1_T);

    translate([pcb_L*0.28, -pcb_W*0.18, pcb_T/2 + small2_T/2 - overlap])
      chip_body(small2_L, small2_W, small2_T);

    // Heatsink (center, taller)
    translate([0, 0, pcb_T/2 + heatsink_H/2 - overlap])
      heatsink_body();

    // Extra small chips to better match side views (two small blue parts near top in right view)
    translate([pcb_L*0.05, pcb_W*0.22, pcb_T/2 + 1.2/2 - overlap])
      chip_body(6, 4, 1.2);

    translate([pcb_L*0.18, pcb_W*0.22, pcb_T/2 + 1.2/2 - overlap])
      chip_body(5, 3.5, 1.2);

    // Larger blue part near lower-left in right view
    translate([-pcb_L*0.18, -pcb_W*0.22, pcb_T/2 + 2.2/2 - overlap])
      chip_body(10, 8, 2.2);
  }
}

//====================
// Bottom-side components (z-)
// Ensure they overlap into PCB so the whole model is ONE connected solid.
//====================
module bottom_side_components() {
  union() {
    // Bottom central block (seen in bottom view)
    translate([0, 0, -pcb_T/2 - bottom_chip_T/2 + overlap])
      color([0.65, 0.65, 0.68])
        cube([bottom_chip_L, bottom_chip_W, bottom_chip_T], center=true);

    // Two small bottom chips (left/right)
    translate([-pcb_L*0.25, 0, -pcb_T/2 - bottom_small_T/2 + overlap])
      chip_body(bottom_small_L, bottom_small_W, bottom_small_T);

    translate([ pcb_L*0.25, 0, -pcb_T/2 - bottom_small_T/2 + overlap])
      chip_body(bottom_small_L, bottom_small_W, bottom_small_T);

    // Bottom-side connector-like blocks (to echo bottom view end blocks)
    translate([
      -pcb_L/2 + (connector_len*0.75)/2 - overlap,
      pcb_W*0.25,
      -pcb_T/2 - (connector_H*0.7)/2 + overlap
    ]) connector_body(connector_len*0.75, connector_depth*0.9, connector_H*0.7);

    translate([
      pcb_L/2 - (connector_len*0.75)/2 + overlap,
      -pcb_W*0.10,
      -pcb_T/2 - (connector_H*0.7)/2 + overlap
    ]) connector_body(connector_len*0.75, connector_depth*0.9, connector_H*0.7);
  }
}

//====================
// Complete model (single connected solid)
//====================
module complete_mainboard_model() {
  union() {
    pcb_with_holes_and_chamfers();
    top_side_components();
    bottom_side_components();
  }
}

complete_mainboard_model();