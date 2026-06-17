// Parameters
pcb_length = 203.2; //[101.6:406.4:0.1]
pcb_width = 49.53; //[24.765:99.06:0.01]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 3.0; //[1.5:6.0:0.1]
mount_hole_diameter = 3.2; //[2.0:5.0:0.1]
mount_hole_edge_offset_x = 6.0; //[3.0:12.0:0.1]
mount_hole_edge_offset_y = 6.0; //[3.0:12.0:0.1]
hole_clearance_height = 6.0; //[3.0:20.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
silkscreen_thickness = 0.2; //[0.1:0.5:0.05]
silkscreen_margin = 3.0; //[1.0:8.0:0.1]
connector_height = 10.0; //[5.0:20.0:0.5]
connector_depth = 8.0; //[4.0:16.0:0.5]
connector_wall_inset = 2.0; //[1.0:6.0:0.1]
component_block_height = 6.0; //[3.0:15.0:0.5]
component_block_size_x = 18.0; //[9.0:36.0:0.5]
component_block_size_y = 12.0; //[6.0:24.0:0.5]

// PCB Main Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green for PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Corner Cut Cylinders
module corner_cut_cyl(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=pcb_thickness + 2*overlap, center=true);
}

// Corner Cut Boxes
module corner_cut_box(pos) {
  translate(pos)
    cube([corner_radius*2, corner_radius*2, pcb_thickness + 2*overlap], center=true);
}

// Mounting Holes
module mount_hole(pos) {
  translate(pos)
    cylinder(r=mount_hole_diameter/2, h=hole_clearance_height, center=true);
}

// Silkscreen Markings
module silkscreen_markings() {
  color([0.85, 0.85, 0.8]) // Off-white for silkscreen
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap])
    cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
}

// Connector Edge Blocks
module connector_edge_block_1() {
  translate([-pcb_length/2 + (pcb_length*0.22)/2 + connector_wall_inset, pcb_width/2 - connector_depth/2 - connector_wall_inset, pcb_thickness/2 + connector_height/2 - overlap])
    cube([pcb_length*0.22, connector_depth, connector_height], center=true);
}

module connector_edge_block_2() {
  translate([pcb_length/2 - (pcb_length*0.18)/2 - connector_wall_inset, pcb_width/2 - connector_depth/2 - connector_wall_inset, pcb_thickness/2 + connector_height/2 - overlap])
    cube([pcb_length*0.18, connector_depth, connector_height], center=true);
}

// Component Blocks
module component_block_1() {
  translate([-pcb_length*0.15, 0, pcb_thickness/2 + component_block_height/2 - overlap])
    cube([component_block_size_x, component_block_size_y, component_block_height], center=true);
}

module component_cyl_1() {
  translate([pcb_length*0.18, -pcb_width*0.15, pcb_thickness/2 + component_block_height/2 - overlap])
    cylinder(r=component_block_size_y*0.35, h=component_block_height, center=true);
}

// Assemble PCB
module pcb_complete() {
  difference() {
    pcb_main_body();
    corner_cut_box([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0]);
    corner_cut_cyl([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0]);
    corner_cut_box([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0]);
    corner_cut_cyl([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0]);
    corner_cut_box([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0]);
    corner_cut_cyl([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0]);
    corner_cut_box([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0]);
    corner_cut_cyl([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0]);
    mount_hole([-pcb_length/2 + mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0]);
    mount_hole([pcb_length/2 - mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0]);
    mount_hole([pcb_length/2 - mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0]);
    mount_hole([-pcb_length/2 + mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0]);
  }
  union() {
    silkscreen_markings();
    connector_edge_block_1();
    connector_edge_block_2();
    component_block_1();
    component_cyl_1();
  }
}

// Render the complete PCB
pcb_complete();