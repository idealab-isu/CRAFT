// Parameters
board_length = 123.0; //[61.5:246.0:0.5]
board_width = 100.0; //[50.0:200.0:0.5]
board_thickness = 1.6; //[0.8:3.2:0.1]
edge_chamfer = 1.0; //[0.5:2.0:0.1]
corner_cutout_depth = 2.0; //[0.5:4.0:0.1]
mount_hole_diameter = 3.2; //[2.0:5.0:0.1]
mount_hole_edge_offset_x = 6.0; //[3.0:12.0:0.5]
mount_hole_edge_offset_y = 6.0; //[3.0:12.0:0.5]
hole_clearance_height = 6.0; //[3.0:12.0:0.5]
connector_height = 12.0; //[6.0:24.0:0.5]
connector_wall_overlap = 1.0; //[0.5:2.0:0.1]
usb_conn_length = 14.0; //[7.0:28.0:0.5]
usb_conn_width = 12.0; //[6.0:24.0:0.5]
power_conn_length = 18.0; //[9.0:36.0:0.5]
power_conn_width = 14.0; //[7.0:28.0:0.5]
header_length = 40.0; //[20.0:80.0:0.5]
header_width = 6.0; //[3.0:12.0:0.5]
header_height = 8.0; //[4.0:16.0:0.5]
chip_height = 2.0; //[1.0:5.0:0.1]
mcu_length = 20.0; //[10.0:40.0:0.5]
mcu_width = 20.0; //[10.0:40.0:0.5]
driver_length = 10.0; //[5.0:20.0:0.5]
driver_width = 10.0; //[5.0:20.0:0.5]
heatsink_length = 14.0; //[7.0:28.0:0.5]
heatsink_width = 14.0; //[7.0:28.0:0.5]
heatsink_height = 10.0; //[5.0:20.0:0.5]
silkscreen_height = 0.2; //[0.1:0.6:0.05]
silkscreen_margin = 5.0; //[2.0:10.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// Base Shapes
module pcb_board() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([board_length, board_width, board_thickness], center = true);
}

module corner_cutout() {
  cube([edge_chamfer * 2, edge_chamfer * 2, board_thickness + corner_cutout_depth], center = true);
}

module mount_hole_cyl() {
  cylinder(h = hole_clearance_height, r = mount_hole_diameter / 2, center = true);
}

module usb_connector_body() {
  color("DimGray")
  cube([usb_conn_length, usb_conn_width, connector_height], center = true);
}

module power_connector_body() {
  color("DimGray")
  cube([power_conn_length, power_conn_width, connector_height], center = true);
}

module header_body() {
  color("DimGray")
  cube([header_length, header_width, header_height], center = true);
}

module mcu_chip() {
  color("Black")
  cube([mcu_length, mcu_width, chip_height], center = true);
}

module driver_chip() {
  color("Black")
  cube([driver_length, driver_width, chip_height], center = true);
}

module heatsink_block() {
  color("Silver")
  cube([heatsink_length, heatsink_width, heatsink_height], center = true);
}

module silkscreen_border_x() {
  color("White")
  cube([board_length - 2 * silkscreen_margin, silkscreen_height * 6, silkscreen_height], center = true);
}

module silkscreen_border_y() {
  color("White")
  cube([silkscreen_height * 6, board_width - 2 * silkscreen_margin, silkscreen_height], center = true);
}

// Operations
module pcb_with_edge_chamfer_or_fillet() {
  difference() {
    pcb_board();
    translate([board_length / 2 - edge_chamfer, board_width / 2 - edge_chamfer, 0]) corner_cutout();
    translate([-board_length / 2 + edge_chamfer, board_width / 2 - edge_chamfer, 0]) corner_cutout();
    translate([board_length / 2 - edge_chamfer, -board_width / 2 + edge_chamfer, 0]) corner_cutout();
    translate([-board_length / 2 + edge_chamfer, -board_width / 2 + edge_chamfer, 0]) corner_cutout();
  }
}

module pcb_with_mounting_holes() {
  difference() {
    pcb_with_edge_chamfer_or_fillet();
    translate([-board_length / 2 + mount_hole_edge_offset_x, -board_width / 2 + mount_hole_edge_offset_y, 0]) mount_hole_cyl();
    translate([board_length / 2 - mount_hole_edge_offset_x, -board_width / 2 + mount_hole_edge_offset_y, 0]) mount_hole_cyl();
    translate([-board_length / 2 + mount_hole_edge_offset_x, board_width / 2 - mount_hole_edge_offset_y, 0]) mount_hole_cyl();
    translate([board_length / 2 - mount_hole_edge_offset_x, board_width / 2 - mount_hole_edge_offset_y, 0]) mount_hole_cyl();
  }
}

module connectors() {
  union() {
    translate([-board_length / 2 + usb_conn_length / 2 - overlap, 0, board_thickness / 2 + connector_height / 2 - connector_wall_overlap]) usb_connector_body();
    translate([board_length / 2 - power_conn_length / 2 + overlap, 0, board_thickness / 2 + connector_height / 2 - connector_wall_overlap]) power_connector_body();
    translate([0, board_width / 2 - header_width / 2 + overlap, board_thickness / 2 + header_height / 2 - connector_wall_overlap]) header_body();
  }
}

module chips() {
  union() {
    translate([-board_length * 0.10, -board_width * 0.05, board_thickness / 2 + chip_height / 2 - overlap]) mcu_chip();
    translate([board_length * 0.15, -board_width * 0.20, board_thickness / 2 + chip_height / 2 - overlap]) driver_chip();
    translate([board_length * 0.15, -board_width * 0.05, board_thickness / 2 + chip_height / 2 - overlap]) driver_chip();
    translate([board_length * 0.15, board_width * 0.10, board_thickness / 2 + chip_height / 2 - overlap]) driver_chip();
  }
}

module heatsinks() {
  union() {
    translate([board_length * 0.15, -board_width * 0.20, board_thickness / 2 + heatsink_height / 2 - overlap]) heatsink_block();
    translate([board_length * 0.15, -board_width * 0.05, board_thickness / 2 + heatsink_height / 2 - overlap]) heatsink_block();
    translate([board_length * 0.15, board_width * 0.10, board_thickness / 2 + heatsink_height / 2 - overlap]) heatsink_block();
  }
}

module silkscreen_markings() {
  union() {
    translate([0, board_width / 2 - silkscreen_margin, board_thickness / 2 + silkscreen_height / 2 - overlap]) silkscreen_border_x();
    translate([0, -board_width / 2 + silkscreen_margin, board_thickness / 2 + silkscreen_height / 2 - overlap]) silkscreen_border_x();
    translate([-board_length / 2 + silkscreen_margin, 0, board_thickness / 2 + silkscreen_height / 2 - overlap]) silkscreen_border_y();
    translate([board_length / 2 - silkscreen_margin, 0, board_thickness / 2 + silkscreen_height / 2 - overlap]) silkscreen_border_y();
  }
}

// Final Assembly
module pcb_assembly_union() {
  union() {
    pcb_with_mounting_holes();
    connectors();
    chips();
    heatsinks();
    silkscreen_markings();
  }
}

// Render the final PCB assembly
pcb_assembly_union();