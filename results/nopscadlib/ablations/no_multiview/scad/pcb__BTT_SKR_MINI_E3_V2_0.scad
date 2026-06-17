// Parameters
board_length = 100.75; //[50.375:201.5:0.25]
board_width = 70.25; //[35.125:140.5:0.25]
board_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 4; //[2:8:0.5]
mount_hole_diameter = 3.2; //[2.4:4.5:0.1]
mount_hole_edge_offset_x = 6; //[3:12:0.5]
mount_hole_edge_offset_y = 6; //[3:12:0.5]
hole_cut_extra = 0.6; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]
silkscreen_thickness = 0.2; //[0.1:0.6:0.05]
silkscreen_margin = 2; //[1:5:0.5]
connector_height = 10; //[6:20:0.5]
connector_depth = 12; //[6:25:0.5]
connector_wall = 1.5; //[1:3:0.1]
heatsink_size_x = 14; //[8:28:0.5]
heatsink_size_y = 14; //[8:28:0.5]
heatsink_height = 8; //[4:20:0.5]
ic_qfp_size = 14; //[8:28:0.5]
ic_qfp_height = 2; //[1:5:0.1]
ic_small_size_x = 8; //[4:16:0.5]
ic_small_size_y = 6; //[3:12:0.5]
ic_small_height = 1.6; //[0.8:4:0.1]
screw_terminal_size_x = 20; //[10:40:0.5]
screw_terminal_size_y = 12; //[8:20:0.5]
screw_terminal_height = 12; //[8:25:0.5]

// Mainboard PCB with rounded corners and mounting holes
module pcb_mainboard() {
  difference() {
    // PCB base
    color([0.0, 0.4, 0.2])
    cube([board_length, board_width, board_thickness], center = true);
    
    // Corner cuts
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (board_length / 2 - corner_radius), y * (board_width / 2 - corner_radius), 0])
        cylinder(r = corner_radius, h = board_thickness + hole_cut_extra, center = true);
    }
    
    // Mounting holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (board_length / 2 - mount_hole_edge_offset_x), y * (board_width / 2 - mount_hole_edge_offset_y), 0])
        cylinder(r = mount_hole_diameter / 2, h = board_thickness + hole_cut_extra, center = true);
    }
  }
}

// Silkscreen layer
module silkscreen_layer() {
  union() {
    // Silkscreen border
    translate([0, 0, board_thickness / 2 + silkscreen_thickness / 2 - overlap])
      color("White")
      cube([board_length - 2 * silkscreen_margin, board_width - 2 * silkscreen_margin, silkscreen_thickness], center = true);
    
    // Silkscreen markings
    translate([0, board_width * 0.25, board_thickness / 2 + silkscreen_thickness / 2 - overlap])
      cube([board_length * 0.35, board_width * 0.08, silkscreen_thickness], center = true);
  }
}

// Connectors
module connectors() {
  union() {
    // USB connector
    translate([-board_length / 2 + (board_length * 0.18) / 2 - overlap, 0, board_thickness / 2 + connector_height / 2 - overlap])
      color("DimGray")
      cube([board_length * 0.18, connector_depth, connector_height], center = true);
    
    // Header connector
    translate([0, board_width / 2 - (board_width * 0.08) / 2 + overlap, board_thickness / 2 + (connector_height * 0.6) / 2 - overlap])
      cube([board_length * 0.55, board_width * 0.08, connector_height * 0.6], center = true);
    
    // Power jack
    translate([board_length / 2 - (board_length * 0.16) / 2 + overlap, -board_width * 0.15, board_thickness / 2 + (connector_height * 0.9) / 2 - overlap])
      cube([board_length * 0.16, connector_depth * 0.9, connector_height * 0.9], center = true);
  }
}

// Heatsinks
module heatsinks() {
  union() {
    // Heatsink 1
    translate([-board_length * 0.15, -board_width * 0.1, board_thickness / 2 + heatsink_height / 2 - overlap])
      color("Silver")
      cube([heatsink_size_x, heatsink_size_y, heatsink_height], center = true);
    
    // Heatsink 2
    translate([board_length * 0.15, -board_width * 0.1, board_thickness / 2 + heatsink_height / 2 - overlap])
      cube([heatsink_size_x, heatsink_size_y, heatsink_height], center = true);
  }
}

// IC Packages
module ic_packages() {
  union() {
    // Main QFP IC
    translate([0, 0, board_thickness / 2 + ic_qfp_height / 2 - overlap])
      color("Black")
      cube([ic_qfp_size, ic_qfp_size, ic_qfp_height], center = true);
    
    // Small IC 1
    translate([-board_length * 0.25, board_width * 0.18, board_thickness / 2 + ic_small_height / 2 - overlap])
      cube([ic_small_size_x, ic_small_size_y, ic_small_height], center = true);
    
    // Small IC 2
    translate([board_length * 0.25, board_width * 0.18, board_thickness / 2 + ic_small_height / 2 - overlap])
      cube([ic_small_size_x, ic_small_size_y, ic_small_height], center = true);
  }
}

// Screw Terminals
module screw_terminals() {
  translate([0, -board_width / 2 + screw_terminal_size_y / 2 - overlap, board_thickness / 2 + screw_terminal_height / 2 - overlap])
    color("DimGray")
    cube([screw_terminal_size_x, screw_terminal_size_y, screw_terminal_height], center = true);
}

// Complete Mainboard Model
module complete_mainboard_model() {
  union() {
    pcb_mainboard();
    silkscreen_layer();
    connectors();
    heatsinks();
    ic_packages();
    screw_terminals();
  }
}

// Render the complete model
complete_mainboard_model();