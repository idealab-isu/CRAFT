// Parameters
pcb_length = 65.0; //[32.5:130.0:0.1]
pcb_width = 30.6; //[15.3:61.2:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
edge_fillet_radius = 2.0; //[1.0:4.0:0.1]
mount_hole_diameter = 3.2; //[2.0:6.0:0.1]
mount_hole_edge_offset_x = 4.0; //[2.0:10.0:0.1]
mount_hole_edge_offset_y = 3.5; //[2.0:10.0:0.1]
keepout_height = 6.0; //[2.0:15.0:0.5]
keepout_thickness_overlap = 0.8; //[0.5:2.0:0.1]
connector_length = 14.0; //[7.0:28.0:0.5]
connector_width = 8.0; //[4.0:16.0:0.5]
connector_height = 5.0; //[2.0:12.0:0.5]
connector_edge_inset = 1.0; //[0.5:4.0:0.1]
silkscreen_height = 0.2; //[0.1:0.6:0.05]
silkscreen_overlap = 0.3; //[0.1:1.0:0.05]

// Base Shapes
module pcb_main_board() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

module corner_cutout_cyl() {
  cylinder(r=edge_fillet_radius, h=pcb_thickness*2, center=true);
}

module mount_hole_cyl() {
  cylinder(r=mount_hole_diameter/2, h=pcb_thickness*3, center=true);
}

module keepout_block_1() {
  color([0.85, 0.85, 0.8]) // Off-white for keepout
  translate([-pcb_length/2 + 18/2 + 10, 0, pcb_thickness/2 + keepout_height/2 - keepout_thickness_overlap])
    cube([18, 12, keepout_height], center=true);
}

module keepout_block_2() {
  color([0.85, 0.85, 0.8]) // Off-white for keepout
  translate([pcb_length/2 - 16/2 - 12, pcb_width/2 - 10/2 - 6, pcb_thickness/2 + keepout_height/2 - keepout_thickness_overlap])
    cube([16, 10, keepout_height], center=true);
}

module connector_outline() {
  color([0.1, 0.1, 0.6]) // Blue for connector
  translate([pcb_length/2 - connector_edge_inset - connector_length/2, 0, pcb_thickness/2 + connector_height/2 - keepout_thickness_overlap])
    cube([connector_length, connector_width, connector_height], center=true);
}

module silkscreen_marking_1() {
  color([1, 1, 1]) // White for silkscreen
  translate([0, pcb_width/2 - 0.6/2 - 1.2, pcb_thickness/2 + silkscreen_height/2 - silkscreen_overlap])
    cube([pcb_length*0.7, 0.6, silkscreen_height], center=true);
}

module silkscreen_marking_2() {
  color([1, 1, 1]) // White for silkscreen
  translate([-pcb_length/2 + 0.6/2 + 1.2, 0, pcb_thickness/2 + silkscreen_height/2 - silkscreen_overlap])
    cube([0.6, pcb_width*0.7, silkscreen_height], center=true);
}

// Operations
module corner_fillets() {
  difference() {
    pcb_main_board();
    translate([-pcb_length/2 + edge_fillet_radius, pcb_width/2 - edge_fillet_radius, 0]) corner_cutout_cyl();
    translate([pcb_length/2 - edge_fillet_radius, pcb_width/2 - edge_fillet_radius, 0]) corner_cutout_cyl();
    translate([-pcb_length/2 + edge_fillet_radius, -pcb_width/2 + edge_fillet_radius, 0]) corner_cutout_cyl();
    translate([pcb_length/2 - edge_fillet_radius, -pcb_width/2 + edge_fillet_radius, 0]) corner_cutout_cyl();
  }
}

module mounting_holes() {
  difference() {
    corner_fillets();
    translate([-pcb_length/2 + mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0]) mount_hole_cyl();
    translate([pcb_length/2 - mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0]) mount_hole_cyl();
    translate([-pcb_length/2 + mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0]) mount_hole_cyl();
    translate([pcb_length/2 - mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0]) mount_hole_cyl();
  }
}

module component_keepout_blocks() {
  union() {
    keepout_block_1();
    keepout_block_2();
  }
}

module silkscreen_markings() {
  union() {
    silkscreen_marking_1();
    silkscreen_marking_2();
  }
}

// Final Model
module pcb_complete_model() {
  union() {
    mounting_holes();
    component_keepout_blocks();
    connector_outline();
    silkscreen_markings();
  }
}

// Render the complete PCB model
pcb_complete_model();