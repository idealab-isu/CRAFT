// Parameters
pcb_L = 20; //[10:40:0.1]
pcb_W = 14; //[7:28:0.1]
pcb_T = 1.6; //[0.8:3.2:0.1]
eps = 0.8; //[0.2:2:0.1]
hole_d = 3; //[1.5:5:0.1]
hole_edge_margin = 2.5; //[1.5:5:0.1]
chamfer = 0.8; //[0.2:2:0.1]
silk_T = 0.1; //[0.05:0.3:0.05]
silk_margin = 0.6; //[0.2:2:0.1]
silk_line_w = 0.4; //[0.2:1:0.1]
comp_H = 2.5; //[1:6:0.1]
comp_L = 10; //[5:18:0.1]
comp_W = 8; //[4:12:0.1]
header_rows = 2; //[1:2:1]
header_pins = 8; //[4:16:1]
header_pitch = 2.54; //[2:3:0.01]
header_body_W = 5.1; //[3:8:0.1]
header_body_H = 2.5; //[1.5:5:0.1]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green for PCB
  cube([pcb_L, pcb_W, pcb_T], center=true);
}

// Mounting Holes
module mounting_hole() {
  cylinder(h=pcb_T + 2*eps, r=hole_d/2, center=true);
}

// Chamfer Cut
module chamfer_cut() {
  cube([chamfer, chamfer, pcb_T + 2*eps], center=true);
}

// Silkscreen Line
module silk_line(length, width, height) {
  cube([length, width, height], center=true);
}

// Component Placeholder
module component_placeholder() {
  color([0.85, 0.85, 0.8]) // Off-white for components
  cube([comp_L, comp_W, comp_H], center=true);
}

// Pin Header Block
module pin_header_block() {
  color([0.1, 0.1, 0.6]) // Blue for headers
  cube([(header_pins - 1)*header_pitch + header_pitch, header_body_W, header_body_H], center=true);
}

// Assemble PCB
module complete_model() {
  difference() {
    pcb_main_body();
    // Chamfer corners
    translate([-pcb_L/2 + chamfer/2, -pcb_W/2 + chamfer/2, 0]) chamfer_cut();
    translate([pcb_L/2 - chamfer/2, -pcb_W/2 + chamfer/2, 0]) chamfer_cut();
    translate([-pcb_L/2 + chamfer/2, pcb_W/2 - chamfer/2, 0]) chamfer_cut();
    translate([pcb_L/2 - chamfer/2, pcb_W/2 - chamfer/2, 0]) chamfer_cut();
    // Mounting holes
    translate([-pcb_L/2 + hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0]) mounting_hole();
    translate([pcb_L/2 - hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0]) mounting_hole();
    translate([-pcb_L/2 + hole_edge_margin, pcb_W/2 - hole_edge_margin, 0]) mounting_hole();
    translate([pcb_L/2 - hole_edge_margin, pcb_W/2 - hole_edge_margin, 0]) mounting_hole();
  }
  
  // Silkscreen markings
  union() {
    translate([0, pcb_W/2 - silk_margin - silk_line_w/2, pcb_T/2 + silk_T/2 - eps/4]) silk_line(pcb_L - 2*silk_margin, silk_line_w, silk_T);
    translate([0, -pcb_W/2 + silk_margin + silk_line_w/2, pcb_T/2 + silk_T/2 - eps/4]) silk_line(pcb_L - 2*silk_margin, silk_line_w, silk_T);
    translate([pcb_L/2 - silk_margin - silk_line_w/2, 0, pcb_T/2 + silk_T/2 - eps/4]) silk_line(silk_line_w, pcb_W - 2*silk_margin, silk_T);
    translate([-pcb_L/2 + silk_margin + silk_line_w/2, 0, pcb_T/2 + silk_T/2 - eps/4]) silk_line(silk_line_w, pcb_W - 2*silk_margin, silk_T);
  }
  
  // Component placeholders
  translate([0, 0, pcb_T/2 + comp_H/2 - eps]) component_placeholder();
  
  // Pin headers
  translate([0, pcb_W/2 - header_body_W/2 + eps, pcb_T/2 + header_body_H/2 - eps]) pin_header_block();
}

// Render the complete model
complete_model();