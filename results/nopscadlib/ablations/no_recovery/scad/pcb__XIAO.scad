// Parameters
pcb_L = 21.0; //[10.5:42.0:0.5]
pcb_W = 18.0; //[9.0:36.0:0.5]
pcb_T = 1.2; //[0.6:2.4:0.1]
hole_d = 2.2; //[1.0:4.4:0.1]
hole_edge_margin = 3.0; //[1.5:6.0:0.1]
hole_clearance_z = 0.5; //[0.2:2.0:0.1]
chamfer_size = 1.0; //[0.5:2.0:0.1]
marking_T = 0.1; //[0.05:0.3:0.05]
marking_line_W = 0.4; //[0.2:1.0:0.1]
marking_inset = 1.0; //[0.5:3.0:0.1]
pad_T = 0.05; //[0.02:0.2:0.01]
pad_L = 1.6; //[0.8:3.2:0.1]
pad_W = 1.0; //[0.5:2.0:0.1]
pad_pitch = 2.54; //[1.27:5.08:0.01]
pad_row_y = 0.0; //[-6.0:6.0:0.1]
outline_T = 0.08; //[0.04:0.2:0.01]
outline_L = 10.0; //[5.0:20.0:0.5]
outline_W = 6.0; //[3.0:12.0:0.5]
outline_line_W = 0.4; //[0.2:1.0:0.1]
outline_center_x = 0.0; //[-5.0:5.0:0.1]
outline_center_y = 4.0; //[-6.0:6.0:0.1]
overlap = 0.6; //[0.3:1.5:0.1]

// PCB Body with Holes and Chamfer
module pcb_body_with_holes_and_chamfer() {
  difference() {
    color([0.0, 0.4, 0.2]) // PCB color
    cube([pcb_L, pcb_W, pcb_T], center=true);
    union() {
      translate([-pcb_L/2 + hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0])
        cylinder(h=pcb_T + hole_clearance_z, r=hole_d/2, center=true);
      translate([pcb_L/2 - hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0])
        cylinder(h=pcb_T + hole_clearance_z, r=hole_d/2, center=true);
      translate([-pcb_L/2 + hole_edge_margin, pcb_W/2 - hole_edge_margin, 0])
        cylinder(h=pcb_T + hole_clearance_z, r=hole_d/2, center=true);
      translate([pcb_L/2 - hole_edge_margin, pcb_W/2 - hole_edge_margin, 0])
        cylinder(h=pcb_T + hole_clearance_z, r=hole_d/2, center=true);
    }
    union() {
      translate([pcb_L/2 - chamfer_size/2, pcb_W/2 - chamfer_size/2, 0])
        cube([chamfer_size, chamfer_size, pcb_T + hole_clearance_z], center=true);
      translate([-pcb_L/2 + chamfer_size/2, pcb_W/2 - chamfer_size/2, 0])
        cube([chamfer_size, chamfer_size, pcb_T + hole_clearance_z], center=true);
      translate([-pcb_L/2 + chamfer_size/2, -pcb_W/2 + chamfer_size/2, 0])
        cube([chamfer_size, chamfer_size, pcb_T + hole_clearance_z], center=true);
      translate([pcb_L/2 - chamfer_size/2, -pcb_W/2 + chamfer_size/2, 0])
        cube([chamfer_size, chamfer_size, pcb_T + hole_clearance_z], center=true);
    }
  }
}

// Silkscreen Markings
module silkscreen_markings() {
  color("White")
  union() {
    translate([0, pcb_W/2 - marking_inset, pcb_T/2 + marking_T/2 - overlap])
      cube([pcb_L - 2*marking_inset, marking_line_W, marking_T], center=true);
    translate([0, -pcb_W/2 + marking_inset, pcb_T/2 + marking_T/2 - overlap])
      cube([pcb_L - 2*marking_inset, marking_line_W, marking_T], center=true);
    translate([-pcb_L/2 + marking_inset, 0, pcb_T/2 + marking_T/2 - overlap])
      cube([marking_line_W, pcb_W - 2*marking_inset, marking_T], center=true);
    translate([pcb_L/2 - marking_inset, 0, pcb_T/2 + marking_T/2 - overlap])
      cube([marking_line_W, pcb_W - 2*marking_inset, marking_T], center=true);
  }
}

// Copper Pads
module copper_pads() {
  color([0.72, 0.45, 0.2]) // Copper color
  union() {
    translate([-1.5*pad_pitch, pad_row_y, pcb_T/2 + pad_T/2 - overlap])
      cube([pad_L, pad_W, pad_T], center=true);
    translate([-0.5*pad_pitch, pad_row_y, pcb_T/2 + pad_T/2 - overlap])
      cube([pad_L, pad_W, pad_T], center=true);
    translate([0.5*pad_pitch, pad_row_y, pcb_T/2 + pad_T/2 - overlap])
      cube([pad_L, pad_W, pad_T], center=true);
    translate([1.5*pad_pitch, pad_row_y, pcb_T/2 + pad_T/2 - overlap])
      cube([pad_L, pad_W, pad_T], center=true);
  }
}

// Component Outline
module components_outline() {
  color([0.85, 0.85, 0.8]) // Off-white for outline
  difference() {
    translate([outline_center_x, outline_center_y, pcb_T/2 + outline_T/2 - overlap])
      cube([outline_L, outline_W, outline_T], center=true);
    translate([outline_center_x, outline_center_y, pcb_T/2 + outline_T/2 - overlap])
      cube([outline_L - 2*outline_line_W, outline_W - 2*outline_line_W, outline_T + overlap], center=true);
  }
}

// Complete PCB
module pcb_complete() {
  union() {
    pcb_body_with_holes_and_chamfer();
    silkscreen_markings();
    copper_pads();
    components_outline();
  }
}

// Render the complete PCB
pcb_complete();