// Parameters
pcb_length = 203.2; //[101.6:406.4:0.1]
pcb_width = 49.53; //[24.765:99.06:0.01]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
hole_diameter = 3.2; //[2.0:6.0:0.1]
hole_edge_offset_x = 6.0; //[3.0:15.0:0.5]
hole_edge_offset_y = 6.0; //[3.0:15.0:0.5]
chamfer_size = 1.0; //[0.5:3.0:0.1]
silkscreen_thickness = 0.1; //[0.05:0.3:0.01]
silkscreen_margin = 2.0; //[0.5:6.0:0.5]
component_height = 8.0; //[3.0:20.0:0.5]
connector_height = 12.0; //[5.0:30.0:0.5]
connector_depth_y = 10.0; //[5.0:25.0:0.5]
connector_length_x = 18.0; //[8.0:40.0:0.5]
component_block_x = 25.0; //[10.0:60.0:0.5]
component_block_y = 20.0; //[8.0:40.0:0.5]
overlap = 0.8; //[0.2:2.0:0.1]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Mounting Holes
module mounting_hole(x, y) {
  translate([x, y, 0])
    cylinder(h=pcb_thickness + 2*overlap, r=hole_diameter/2, center=true);
}

module mounting_holes() {
  union() {
    mounting_hole(-pcb_length/2 + hole_edge_offset_x, -pcb_width/2 + hole_edge_offset_y);
    mounting_hole(pcb_length/2 - hole_edge_offset_x, -pcb_width/2 + hole_edge_offset_y);
    mounting_hole(-pcb_length/2 + hole_edge_offset_x, pcb_width/2 - hole_edge_offset_y);
    mounting_hole(pcb_length/2 - hole_edge_offset_x, pcb_width/2 - hole_edge_offset_y);
  }
}

// Edge Chamfer
module board_edge_chamfer_cut() {
  translate([0, 0, pcb_thickness/2 - (chamfer_size + overlap)/2])
    cube([pcb_length - 2*chamfer_size, pcb_width - 2*chamfer_size, chamfer_size + overlap], center=true);
}

// Silkscreen Markings
module silkscreen_markings() {
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap/2])
    color("White")
    cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
}

// Connectors
module connector(x) {
  translate([x, 0, pcb_thickness/2 + connector_height/2 - overlap])
    color("DimGray")
    cube([connector_length_x, connector_depth_y, connector_height], center=true);
}

// Components
module component_block(x, y, z) {
  translate([x, y, z])
    color("Black")
    cube([component_block_x, component_block_y, component_height], center=true);
}

module component_block_2() {
  translate([pcb_length/4, pcb_width/4 - component_block_y*0.3, pcb_thickness/2 + (component_height*0.7)/2 - overlap])
    color("Black")
    cube([component_block_x*0.8, component_block_y*0.6, component_height*0.7], center=true);
}

// Complete Board Model
module complete_board_model() {
  difference() {
    pcb_main_body();
    mounting_holes();
    board_edge_chamfer_cut();
  }
  union() {
    silkscreen_markings();
    connector(-pcb_length/2 + connector_length_x/2 - overlap);
    connector(pcb_length/2 - connector_length_x/2 + overlap);
    component_block(-pcb_length/4, 0, pcb_thickness/2 + component_height/2 - overlap);
    component_block_2();
  }
}

// Render the complete board model
complete_board_model();