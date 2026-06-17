// Parameters
pcb_length = 80.4; //[40.2:160.8:0.1]
pcb_width = 36.3; //[18.15:72.6:0.1]
pcb_thickness = 1.5; //[0.8:3:0.1]
corner_radius = 3; //[1.5:6:0.1]
hole_diameter = 3.2; //[2:5:0.1]
hole_edge_margin_x = 6; //[3:12:0.1]
hole_edge_margin_y = 5; //[3:10:0.1]
hole_cut_extra = 0.4; //[0.2:1.5:0.1]
connectors_height = 8; //[4:16:0.5]
connectors_depth = 10; //[5:20:0.5]
connectors_wall_overlap = 0.8; //[0.5:2:0.1]
chip_height = 2.2; //[1:5:0.1]
chip_overlap = 0.6; //[0.3:1.5:0.1]
silkscreen_height = 0.2; //[0.1:0.6:0.05]
silkscreen_overlap = 0.3; //[0.2:1:0.05]

// Main PCB Body with Rounded Corners
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  hull() {
    translate([0, 0, 0])
      cube([pcb_length, pcb_width, pcb_thickness], center=true);
    translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0])
      cylinder(r=corner_radius, h=pcb_thickness, center=true);
    translate([-(pcb_length/2 - corner_radius), pcb_width/2 - corner_radius, 0])
      cylinder(r=corner_radius, h=pcb_thickness, center=true);
    translate([-(pcb_length/2 - corner_radius), -(pcb_width/2 - corner_radius), 0])
      cylinder(r=corner_radius, h=pcb_thickness, center=true);
    translate([pcb_length/2 - corner_radius, -(pcb_width/2 - corner_radius), 0])
      cylinder(r=corner_radius, h=pcb_thickness, center=true);
  }
}

// Mounting Holes
module mounting_holes() {
  color("Black")
  for (x = [-1, 1])
    for (y = [-1, 1])
      translate([x * (pcb_length/2 - hole_edge_margin_x), y * (pcb_width/2 - hole_edge_margin_y), 0])
        cylinder(r=hole_diameter/2, h=pcb_thickness + hole_cut_extra, center=true);
}

// Connectors
module connectors() {
  color([0.15, 0.15, 0.17]) // Black anodized aluminum
  union() {
    translate([-pcb_length*0.22, pcb_width/2 - connectors_depth/2 + connectors_wall_overlap, pcb_thickness/2 + connectors_height/2 - connectors_wall_overlap])
      cube([pcb_length*0.22, connectors_depth, connectors_height], center=true);
    translate([pcb_length*0.18, pcb_width/2 - connectors_depth/2 + connectors_wall_overlap, pcb_thickness/2 + (connectors_height*0.85)/2 - connectors_wall_overlap])
      cube([pcb_length*0.18, connectors_depth, connectors_height*0.85], center=true);
    translate([pcb_length/2 - (pcb_length*0.16)/2 - corner_radius, -pcb_width*0.15, pcb_thickness/2 + (connectors_height*0.7)/2 - connectors_wall_overlap])
      cube([pcb_length*0.16, connectors_depth*0.8, connectors_height*0.7], center=true);
  }
}

// Chips and Components
module chips_components() {
  color([0.4, 0.4, 0.43]) // Steel parts
  union() {
    translate([-pcb_length*0.05, 0, pcb_thickness/2 + chip_height/2 - chip_overlap])
      cube([pcb_length*0.18, pcb_width*0.28, chip_height], center=true);
    translate([pcb_length*0.22, -pcb_width*0.18, pcb_thickness/2 + (chip_height*0.9)/2 - chip_overlap])
      cube([pcb_length*0.12, pcb_width*0.18, chip_height*0.9], center=true);
    translate([pcb_length*0.22, pcb_width*0.18, pcb_thickness/2 + (chip_height*0.9)/2 - chip_overlap])
      cube([pcb_length*0.12, pcb_width*0.18, chip_height*0.9], center=true);
    translate([-pcb_length*0.32, -pcb_width*0.22, pcb_thickness/2 + (chip_height*0.8)/2 - chip_overlap])
      cube([pcb_length*0.1, pcb_width*0.14, chip_height*0.8], center=true);
  }
}

// Silkscreen Markings
module silkscreen_markings() {
  color("White")
  union() {
    translate([0, pcb_width/2 - (pcb_width*0.03)/2 - corner_radius/2, pcb_thickness/2 + silkscreen_height/2 - silkscreen_overlap])
      cube([pcb_length - 2*corner_radius, pcb_width*0.03, silkscreen_height], center=true);
    translate([-pcb_length/2 + (pcb_length*0.03)/2 + corner_radius/2, 0, pcb_thickness/2 + silkscreen_height/2 - silkscreen_overlap])
      cube([pcb_length*0.03, pcb_width - 2*corner_radius, silkscreen_height], center=true);
  }
}

// Complete PCB Model
module pcb_complete_model() {
  difference() {
    pcb_main_body();
    mounting_holes();
  }
  connectors();
  chips_components();
  silkscreen_markings();
}

// Render the complete model
pcb_complete_model();