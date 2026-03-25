// Parameters
pcb_length = 20.0; //[10.0:40.0:0.5]
pcb_width = 14.0; //[7.0:28.0:0.5]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
edge_chamfer = 0.6; //[0.3:1.2:0.1]
corner_cutout_height = 2.0; //[1.0:4.0:0.25]
mount_hole_diameter = 2.0; //[1.0:4.0:0.1]
mount_hole_edge_margin_x = 2.5; //[1.0:6.0:0.25]
mount_hole_edge_margin_y = 2.5; //[1.0:6.0:0.25]
hole_cut_extra_z = 0.6; //[0.2:2.0:0.1]
header_block_length = 16.0; //[8.0:32.0:0.5]
header_block_width = 2.6; //[2.0:6.0:0.1]
header_block_height = 6.0; //[3.0:12.0:0.5]
header_overlap = 0.8; //[0.3:1.6:0.1]
ic_length = 6.0; //[3.0:12.0:0.25]
ic_width = 6.0; //[3.0:12.0:0.25]
ic_height = 1.2; //[0.6:3.0:0.1]
ic_overlap = 0.4; //[0.2:1.0:0.1]
passive_length = 3.2; //[1.6:6.4:0.1]
passive_width = 1.6; //[0.8:3.2:0.1]
passive_height = 1.0; //[0.5:2.5:0.1]
passive_overlap = 0.3; //[0.2:0.8:0.1]
heatsink_pad_length = 8.0; //[4.0:16.0:0.5]
heatsink_pad_width = 8.0; //[4.0:16.0:0.5]
heatsink_pad_thickness = 0.2; //[0.05:0.6:0.05]
heatsink_pad_overlap = 0.2; //[0.1:0.6:0.05]
silkscreen_thickness = 0.1; //[0.05:0.3:0.05]
silkscreen_inset = 1.0; //[0.5:2.5:0.1]
silkscreen_overlap = 0.2; //[0.1:0.6:0.05]
copper_thickness = 0.05; //[0.02:0.2:0.01]
copper_overlap = 0.2; //[0.1:0.6:0.05]
trace_width = 0.8; //[0.3:2.0:0.1]
pad_size = 1.6; //[0.8:3.2:0.1]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green for PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Corner Cutouts for Chamfer
module corner_cutout() {
  cube([edge_chamfer*2, edge_chamfer*2, pcb_thickness + corner_cutout_height], center=true);
}

// Mounting Holes
module mounting_hole() {
  cylinder(r=mount_hole_diameter/2, h=pcb_thickness + hole_cut_extra_z, center=true);
}

// Pin Header Block
module pin_header_block() {
  color([0.85, 0.85, 0.8]) // Off-white for headers
  cube([header_block_length, header_block_width, header_block_height], center=true);
}

// Driver IC Package
module driver_ic_package() {
  color([0.1, 0.1, 0.12]) // Black for IC
  cube([ic_length, ic_width, ic_height], center=true);
}

// Passive Component
module passive_component(length, width, height) {
  color([0.85, 0.85, 0.8]) // Off-white for passive components
  cube([length, width, height], center=true);
}

// Heatsink Pad
module heatsink_pad() {
  color([0.75, 0.75, 0.77]) // Silver for heatsink
  cube([heatsink_pad_length, heatsink_pad_width, heatsink_pad_thickness], center=true);
}

// Silkscreen Markings
module silkscreen_frame() {
  color([1, 1, 1]) // White for silkscreen
  cube([pcb_length - silkscreen_inset*2, pcb_width - silkscreen_inset*2, silkscreen_thickness], center=true);
}

// Copper Pads and Traces
module copper_trace(length, width) {
  color([0.72, 0.45, 0.2]) // Copper color
  cube([length, width, copper_thickness], center=true);
}

module copper_pad() {
  color([0.72, 0.45, 0.2]) // Copper color
  cube([pad_size, pad_size, copper_thickness], center=true);
}

// Complete Model
difference() {
  pcb_main_body();
  // Apply corner cutouts
  for (x = [-1, 1], y = [-1, 1]) {
    translate([x * (pcb_length/2 - edge_chamfer), y * (pcb_width/2 - edge_chamfer), 0])
      rotate([0, 0, 45]) corner_cutout();
  }
  // Apply mounting holes
  for (x = [-1, 1], y = [-1, 1]) {
    translate([x * (pcb_length/2 - mount_hole_edge_margin_x), y * (pcb_width/2 - mount_hole_edge_margin_y), 0])
      mounting_hole();
  }
}

// Add components
union() {
  // Pin header
  translate([0, -pcb_width/2 + header_block_width/2 - header_overlap, pcb_thickness/2 + header_block_height/2 - header_overlap])
    pin_header_block();
  
  // Driver IC
  translate([0, 0, pcb_thickness/2 + ic_height/2 - ic_overlap])
    driver_ic_package();
  
  // Passive components
  translate([-pcb_length/2 + passive_length/2 + edge_chamfer, pcb_width/2 - passive_width/2 - edge_chamfer, pcb_thickness/2 + passive_height/2 - passive_overlap])
    passive_component(passive_length, passive_width, passive_height);
  
  translate([pcb_length/2 - passive_width/2 - edge_chamfer, pcb_width/2 - passive_length/2 - edge_chamfer, pcb_thickness/2 + passive_height/2 - passive_overlap])
    passive_component(passive_width, passive_length, passive_height);
  
  // Heatsink pad
  translate([0, 0, pcb_thickness/2 + heatsink_pad_thickness/2 - heatsink_pad_overlap])
    heatsink_pad();
  
  // Silkscreen frame
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - silkscreen_overlap])
    silkscreen_frame();
  
  // Copper trace
  translate([0, 0, pcb_thickness/2 + copper_thickness/2 - copper_overlap])
    copper_trace(pcb_length - silkscreen_inset*2, trace_width);
  
  // Copper pads
  translate([-pcb_length/2 + silkscreen_inset + pad_size/2, -pcb_width/2 + silkscreen_inset + pad_size/2, pcb_thickness/2 + copper_thickness/2 - copper_overlap])
    copper_pad();
  
  translate([pcb_length/2 - silkscreen_inset - pad_size/2, -pcb_width/2 + silkscreen_inset + pad_size/2, pcb_thickness/2 + copper_thickness/2 - copper_overlap])
    copper_pad();
}