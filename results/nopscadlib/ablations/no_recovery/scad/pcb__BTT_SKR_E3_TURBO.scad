// Parameters
pcb_length = 102.0; //[51.0:204.0:0.25]
pcb_width = 90.25; //[45.0:180.5:0.25]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 4.0; //[2.0:8.0:0.25]
hole_diameter = 3.2; //[2.0:5.0:0.1]
hole_edge_offset_x = 6.0; //[3.0:12.0:0.25]
hole_edge_offset_y = 6.0; //[3.0:12.0:0.25]
hole_overlap = 0.5; //[0.2:2.0:0.1]
component_base_overlap = 0.6; //[0.2:2.0:0.1]
silkscreen_thickness = 0.2; //[0.1:0.6:0.05]
silkscreen_inset = 2.0; //[0.5:6.0:0.25]
connector_height = 10.0; //[5.0:20.0:0.5]
connector_depth = 12.0; //[6.0:24.0:0.5]
connector_wall = 1.5; //[0.8:3.0:0.1]
heatsink_size_x = 18.0; //[9.0:36.0:0.5]
heatsink_size_y = 18.0; //[9.0:36.0:0.5]
heatsink_height = 12.0; //[6.0:24.0:0.5]
chip_size_x = 14.0; //[7.0:28.0:0.5]
chip_size_y = 14.0; //[7.0:28.0:0.5]
chip_height = 2.0; //[1.0:6.0:0.1]
small_comp_height = 1.2; //[0.6:4.0:0.1]
small_comp_size = 6.0; //[3.0:12.0:0.25]

// PCB Main Body with Rounded Corners
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  difference() {
    union() {
      translate([0, 0, 0])
        cube([pcb_length, pcb_width, pcb_thickness], center=true);
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (pcb_length/2 - corner_radius), y * (pcb_width/2 - corner_radius), 0])
          cylinder(r=corner_radius, h=pcb_thickness, center=true);
      }
    }
    // Mounting Holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (pcb_length/2 - hole_edge_offset_x), y * (pcb_width/2 - hole_edge_offset_y), 0])
        cylinder(r=hole_diameter/2, h=pcb_thickness + hole_overlap*2, center=true);
    }
  }
}

// Silkscreen Markings
module silkscreen_markings() {
  color("White")
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - component_base_overlap])
    cube([pcb_length - silkscreen_inset*2, pcb_width - silkscreen_inset*2, silkscreen_thickness], center=true);
}

// Connector
module connector() {
  color("Black")
  difference() {
    translate([0, pcb_width/2 + connector_depth/2 - component_base_overlap, pcb_thickness/2 + connector_height/2 - component_base_overlap])
      cube([pcb_length*0.35, connector_depth, connector_height], center=true);
    translate([0, pcb_width/2 + connector_depth/2 - component_base_overlap, pcb_thickness/2 + (connector_height - connector_wall)/2 - component_base_overlap])
      cube([pcb_length*0.35 - connector_wall*2, connector_depth - connector_wall*2, connector_height - connector_wall], center=true);
  }
}

// Heatsink
module heatsink() {
  color("DimGray")
  translate([-pcb_length*0.2, 0, pcb_thickness/2 + heatsink_height/2 - component_base_overlap])
    cube([heatsink_size_x, heatsink_size_y, heatsink_height], center=true);
}

// Main Chip
module chip() {
  color("Black")
  translate([pcb_length*0.15, -pcb_width*0.1, pcb_thickness/2 + chip_height/2 - component_base_overlap])
    cube([chip_size_x, chip_size_y, chip_height], center=true);
}

// Small Components
module small_component(x, y) {
  color("Black")
  translate([x, y, pcb_thickness/2 + small_comp_height/2 - component_base_overlap])
    cube([small_comp_size, small_comp_size, small_comp_height], center=true);
}

// Assemble PCB with Components
module complete_model() {
  pcb_main_body();
  silkscreen_markings();
  connector();
  heatsink();
  chip();
  small_component(-pcb_length*0.25, -pcb_width*0.25);
  small_component(-pcb_length*0.05, -pcb_width*0.3);
  small_component(pcb_length*0.3, pcb_width*0.2);
}

// Render the complete model
complete_model();