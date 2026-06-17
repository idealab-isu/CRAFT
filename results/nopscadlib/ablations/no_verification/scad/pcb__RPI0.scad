// Parameters
pcb_length = 65.0; //[32.5:130.0:0.5]
pcb_width = 30.0; //[15.0:60.0:0.5]
pcb_thickness = 1.4; //[0.7:2.8:0.1]
edge_chamfer = 1.0; //[0.5:2.0:0.1]
hole_diameter = 3.0; //[2.0:4.0:0.1]
hole_edge_offset = 3.5; //[2.0:7.0:0.1]
hole_cut_extra = 0.6; //[0.2:2.0:0.1]
silkscreen_thickness = 0.2; //[0.1:0.4:0.05]
silkscreen_margin = 1.5; //[0.5:4.0:0.1]
silkscreen_border_width = 0.8; //[0.4:2.0:0.1]
component_overlap = 0.8; //[0.5:2.0:0.1]
connector_height = 8.0; //[4.0:16.0:0.5]
connector_length = 14.0; //[8.0:28.0:0.5]
connector_width = 12.0; //[6.0:24.0:0.5]
ic_length = 12.0; //[6.0:24.0:0.5]
ic_width = 12.0; //[6.0:24.0:0.5]
ic_height = 2.0; //[1.0:5.0:0.1]
header_length = 30.0; //[10.0:60.0:0.5]
header_width = 5.0; //[3.0:10.0:0.5]
header_height = 8.5; //[4.0:16.0:0.5]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Edge Chamfer Cutout
module board_edge_chamfer_cutout_corner() {
  cube([edge_chamfer, edge_chamfer, pcb_thickness + hole_cut_extra], center=true);
}

// Mounting Hole Cutter
module mounting_hole_cutter() {
  cylinder(h=pcb_thickness + hole_cut_extra, r=hole_diameter/2, center=true);
}

// Silkscreen Markings
module silkscreen_outer() {
  color("White")
  cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
}

module silkscreen_inner_cut() {
  cube([pcb_length - 2*(silkscreen_margin + silkscreen_border_width), pcb_width - 2*(silkscreen_margin + silkscreen_border_width), silkscreen_thickness + hole_cut_extra], center=true);
}

// Connectors
module connectors() {
  color("Black")
  cube([connector_length, connector_width, connector_height], center=true);
}

// IC Packages
module ic_packages() {
  color("DimGray")
  cube([ic_length, ic_width, ic_height], center=true);
}

// Pin Headers
module pin_headers() {
  color("Silver")
  cube([header_length, header_width, header_height], center=true);
}

// Assemble the SBC Model
module sbc_complete_model() {
  difference() {
    pcb_main_body();
    // Chamfer corners
    for (angle = [0, 90, 180, 270]) {
      rotate([0, 0, angle])
      translate([pcb_length/2 - edge_chamfer/2, pcb_width/2 - edge_chamfer/2, 0])
      board_edge_chamfer_cutout_corner();
    }
    // Mounting holes
    translate([pcb_length/2 - hole_edge_offset, pcb_width/2 - hole_edge_offset, 0])
    mounting_hole_cutter();
    translate([-pcb_length/2 + hole_edge_offset, pcb_width/2 - hole_edge_offset, 0])
    mounting_hole_cutter();
    translate([pcb_length/2 - hole_edge_offset, -pcb_width/2 + hole_edge_offset, 0])
    mounting_hole_cutter();
    translate([-pcb_length/2 + hole_edge_offset, -pcb_width/2 + hole_edge_offset, 0])
    mounting_hole_cutter();
  }
  
  // Silkscreen
  difference() {
    translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - component_overlap/10])
    silkscreen_outer();
    translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - component_overlap/10])
    silkscreen_inner_cut();
  }
  
  // Components
  translate([pcb_length/2 - connector_length/2, 0, pcb_thickness/2 + connector_height/2 - component_overlap])
  connectors();
  
  translate([0, 0, pcb_thickness/2 + ic_height/2 - component_overlap])
  ic_packages();
  
  translate([0, pcb_width/2 - header_width/2, pcb_thickness/2 + header_height/2 - component_overlap])
  pin_headers();
}

// Render the complete SBC model
sbc_complete_model();