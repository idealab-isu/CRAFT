// Parameters
pcb_length = 110.0; //[55.0:220.0:1]
pcb_width = 85.0; //[42.5:170.0:1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 4.0; //[2.0:8.0:0.5]
mount_hole_diameter = 3.2; //[2.0:6.0:0.1]
mount_hole_edge_offset = 6.0; //[3.0:12.0:0.5]
hole_clearance_z = 0.4; //[0.1:1.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
silkscreen_thickness = 0.15; //[0.05:0.4:0.05]
silkscreen_margin = 5.0; //[2.0:12.0:0.5]
silkscreen_frame_width = 1.2; //[0.6:3.0:0.1]
connector_height = 10.0; //[5.0:20.0:0.5]
connector_wall = 2.0; //[1.0:4.0:0.5]
heatsink_height = 8.0; //[4.0:16.0:0.5]
chip_height = 2.0; //[1.0:5.0:0.1]

// Base Shapes
module pcb_corner_cyl(pos) {
  translate(pos)
    cylinder(r=corner_radius, h=pcb_thickness, center=true);
}

module mount_hole(pos) {
  translate(pos)
    cylinder(r=mount_hole_diameter/2, h=pcb_thickness + hole_clearance_z, center=true);
}

module silkscreen_outer_plate() {
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap])
    cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
}

module silkscreen_inner_cut() {
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap])
    cube([pcb_length - 2*(silkscreen_margin + silkscreen_frame_width), pcb_width - 2*(silkscreen_margin + silkscreen_frame_width), silkscreen_thickness + 2*overlap], center=true);
}

module connector_usb() {
  translate([-pcb_length/2 + (12 + 2*connector_wall)/2 - overlap, 0, pcb_thickness/2 + connector_height/2 - overlap])
    cube([12 + 2*connector_wall, 14 + 2*connector_wall, connector_height], center=true);
}

module connector_power() {
  translate([pcb_length/2 - (18 + 2*connector_wall)/2 + overlap, -pcb_width/2 + (10 + 2*connector_wall)/2 - overlap, pcb_thickness/2 + connector_height/2 - overlap])
    cube([18 + 2*connector_wall, 10 + 2*connector_wall, connector_height], center=true);
}

module connector_stepper(pos) {
  translate(pos)
    cube([10 + 2*connector_wall, 8 + 2*connector_wall, connector_height*0.8], center=true);
}

module chip(pos, size) {
  translate(pos)
    cube(size, center=true);
}

module heatsink(pos) {
  translate(pos)
    cube([16, 16, heatsink_height], center=true);
}

// Operations
module board_corner_radius() {
  hull() {
    pcb_corner_cyl([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0]);
    pcb_corner_cyl([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0]);
    pcb_corner_cyl([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0]);
    pcb_corner_cyl([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0]);
  }
}

module mounting_holes() {
  union() {
    mount_hole([-pcb_length/2 + mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset, 0]);
    mount_hole([pcb_length/2 - mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset, 0]);
    mount_hole([pcb_length/2 - mount_hole_edge_offset, pcb_width/2 - mount_hole_edge_offset, 0]);
    mount_hole([-pcb_length/2 + mount_hole_edge_offset, pcb_width/2 - mount_hole_edge_offset, 0]);
  }
}

module pcb_main_body() {
  difference() {
    board_corner_radius();
    mounting_holes();
  }
}

module silkscreen_markings() {
  difference() {
    silkscreen_outer_plate();
    silkscreen_inner_cut();
  }
}

module connectors() {
  union() {
    connector_usb();
    connector_power();
    connector_stepper([pcb_length/2 - (10 + 2*connector_wall)/2 + overlap, pcb_width/2 - (8 + 2*connector_wall)/2 + overlap, pcb_thickness/2 + (connector_height*0.8)/2 - overlap]);
    connector_stepper([pcb_length/2 - (10 + 2*connector_wall)/2 + overlap, pcb_width/2 - (8 + 2*connector_wall)/2 - (8 + 2*connector_wall) - overlap, pcb_thickness/2 + (connector_height*0.8)/2 - overlap]);
  }
}

module chips_components() {
  union() {
    chip([0, 0, pcb_thickness/2 + chip_height/2 - overlap], [20, 20, chip_height]);
    chip([pcb_length*0.2, pcb_width*0.15, pcb_thickness/2 + chip_height/2 - overlap], [12, 12, chip_height]);
    chip([pcb_length*0.2, -pcb_width*0.15, pcb_thickness/2 + chip_height/2 - overlap], [12, 12, chip_height]);
  }
}

module heatsinks() {
  union() {
    heatsink([pcb_length*0.2, pcb_width*0.15, pcb_thickness/2 + heatsink_height/2 - overlap]);
    heatsink([pcb_length*0.2, -pcb_width*0.15, pcb_thickness/2 + heatsink_height/2 - overlap]);
  }
}

// Final Output
module mainboard_complete() {
  union() {
    pcb_main_body();
    silkscreen_markings();
    connectors();
    chips_components();
    heatsinks();
  }
}

// Render the complete mainboard
color([0.0, 0.4, 0.2]) mainboard_complete(); // PCB color