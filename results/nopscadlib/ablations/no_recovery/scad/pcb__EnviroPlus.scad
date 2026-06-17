// Parameters
board_length = 65.0; //[32.5:130.0:0.1]
board_width = 30.6; //[15.3:61.2:0.1]
board_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 3.0; //[1.0:6.0:0.1]
hole_diameter = 3.2; //[2.0:4.5:0.1]
hole_edge_offset = 4.0; //[2.5:8.0:0.1]
connector_length = 12.0; //[6.0:24.0:0.1]
connector_width = 8.0; //[4.0:16.0:0.1]
connector_height = 5.0; //[2.5:10.0:0.1]
sensor_length = 10.0; //[5.0:20.0:0.1]
sensor_width = 10.0; //[5.0:20.0:0.1]
sensor_height = 2.5; //[1.0:6.0:0.1]
silkscreen_thickness = 0.1; //[0.05:0.3:0.01]
silkscreen_margin = 1.5; //[0.5:4.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// Base Shapes
module pcb_core_box() {
  cube([board_length - 2*corner_radius, board_width - 2*corner_radius, board_thickness], center=true);
}

module corner_cylinder(x, y) {
  translate([x, y, 0])
    cylinder(r=corner_radius, h=board_thickness, center=true);
}

module mount_hole(x, y) {
  translate([x, y, 0])
    cylinder(r=hole_diameter/2, h=board_thickness + 2*overlap, center=true);
}

module connector_body() {
  translate([-(board_length/2) + connector_length/2 - overlap, 0, board_thickness/2 + connector_height/2 - overlap])
    cube([connector_length, connector_width, connector_height], center=true);
}

module sensor_package() {
  translate([board_length/2 - corner_radius - sensor_length/2, 0, board_thickness/2 + sensor_height/2 - overlap])
    cube([sensor_length, sensor_width, sensor_height], center=true);
}

module silkscreen_border() {
  translate([0, 0, board_thickness/2 + silkscreen_thickness/2 - overlap])
    difference() {
      cube([board_length - 2*silkscreen_margin, board_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
      cube([board_length - 2*(silkscreen_margin + 1.2*silkscreen_thickness), board_width - 2*(silkscreen_margin + 1.2*silkscreen_thickness), silkscreen_thickness + 2*overlap], center=true);
    }
}

// Operations
module rounded_corners() {
  union() {
    pcb_core_box();
    corner_cylinder(board_length/2 - corner_radius, board_width/2 - corner_radius);
    corner_cylinder(board_length/2 - corner_radius, -(board_width/2 - corner_radius));
    corner_cylinder(-(board_length/2 - corner_radius), board_width/2 - corner_radius);
    corner_cylinder(-(board_length/2 - corner_radius), -(board_width/2 - corner_radius));
  }
}

module pcb_board() {
  difference() {
    rounded_corners();
    mount_hole(-(board_length/2 - hole_edge_offset), -(board_width/2 - hole_edge_offset));
    mount_hole(-(board_length/2 - hole_edge_offset), board_width/2 - hole_edge_offset);
    mount_hole(board_length/2 - hole_edge_offset, -(board_width/2 - hole_edge_offset));
    mount_hole(board_length/2 - hole_edge_offset, board_width/2 - hole_edge_offset);
  }
}

module complete_model() {
  union() {
    pcb_board();
    connector_body();
    sensor_package();
    silkscreen_border();
  }
}

// Final Output
color([0.0, 0.4, 0.2]) // PCB color
complete_model();