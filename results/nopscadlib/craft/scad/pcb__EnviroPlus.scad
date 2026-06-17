// Parameters
board_L = 65.0; //[32.5:130.0:0.1]
board_W = 30.6; //[15.3:61.2:0.1]
board_T = 1.6; //[0.8:3.2:0.1]
fillet_r = 2.0; //[0.8:4.0:0.1]
hole_d = 3.2; //[2.0:4.5:0.1]
hole_edge_offset = 3.5; //[2.0:7.0:0.1]
copper_t = 0.05; //[0.02:0.15:0.01]
silk_t = 0.05; //[0.02:0.15:0.01]
overlap = 0.8; //[0.5:2.0:0.1]
conn_body_L = 12.0; //[6.0:24.0:0.1]
conn_body_W = 8.0; //[4.0:16.0:0.1]
conn_body_H = 4.0; //[2.0:10.0:0.1]
pin_L = 3.0; //[1.5:6.0:0.1]
pin_W = 0.8; //[0.4:1.6:0.05]
pin_H = 1.2; //[0.6:2.4:0.1]
pin_pitch = 2.54; //[1.27:5.08:0.01]
sensor_body_L = 6.0; //[3.0:12.0:0.1]
sensor_body_W = 6.0; //[3.0:12.0:0.1]
sensor_body_H = 1.2; //[0.6:3.0:0.1]
sensor_cap_r = 1.2; //[0.6:2.5:0.1]
sensor_cap_h = 0.8; //[0.4:2.0:0.1]
pad_L = 2.0; //[1.0:4.0:0.1]
pad_W = 1.2; //[0.6:2.5:0.1]

// Base Shapes
module pcb_main_board_raw() {
  cube([board_L, board_W, board_T], center=true);
}

module corner_cut_cyl() {
  cylinder(r=fillet_r, h=board_T + 2*overlap, center=true);
}

module mount_hole_cyl() {
  cylinder(r=hole_d/2, h=board_T + 2*overlap, center=true);
}

module copper_pad_base() {
  cube([pad_L, pad_W, copper_t], center=true);
}

module silk_rect_base() {
  cube([board_L*0.55, board_W*0.18, silk_t], center=true);
}

module silk_line_base() {
  cube([board_L*0.35, board_W*0.03, silk_t], center=true);
}

module connector_body_base() {
  cube([conn_body_L, conn_body_W, conn_body_H], center=true);
}

module connector_pin_base() {
  cube([pin_L, pin_W, pin_H], center=true);
}

module sensor_body_base() {
  cube([sensor_body_L, sensor_body_W, sensor_body_H], center=true);
}

module sensor_cap_base() {
  cylinder(r=sensor_cap_r, h=sensor_cap_h, center=true);
}

// Operations
module pcb_with_corner_fillets() {
  difference() {
    pcb_main_board_raw();
    union() {
      translate([board_L/2 - fillet_r, board_W/2 - fillet_r, 0]) corner_cut_cyl();
      translate([-(board_L/2 - fillet_r), board_W/2 - fillet_r, 0]) corner_cut_cyl();
      translate([board_L/2 - fillet_r, -(board_W/2 - fillet_r), 0]) corner_cut_cyl();
      translate([-(board_L/2 - fillet_r), -(board_W/2 - fillet_r), 0]) corner_cut_cyl();
    }
  }
}

module pcb_main_board() {
  difference() {
    pcb_with_corner_fillets();
    union() {
      translate([board_L/2 - hole_edge_offset, board_W/2 - hole_edge_offset, 0]) mount_hole_cyl();
      translate([-(board_L/2 - hole_edge_offset), board_W/2 - hole_edge_offset, 0]) mount_hole_cyl();
      translate([board_L/2 - hole_edge_offset, -(board_W/2 - hole_edge_offset), 0]) mount_hole_cyl();
      translate([-(board_L/2 - hole_edge_offset), -(board_W/2 - hole_edge_offset), 0]) mount_hole_cyl();
    }
  }
}

module copper_pads() {
  union() {
    translate([-board_L*0.18, -board_W*0.18, board_T/2 + copper_t/2 - overlap]) copper_pad_base();
    translate([-board_L*0.18, -board_W*0.18 + pin_pitch, board_T/2 + copper_t/2 - overlap]) copper_pad_base();
    translate([-board_L*0.18, -board_W*0.18 + 2*pin_pitch, board_T/2 + copper_t/2 - overlap]) copper_pad_base();
    translate([-board_L*0.18, -board_W*0.18 + 3*pin_pitch, board_T/2 + copper_t/2 - overlap]) copper_pad_base();
  }
}

module silkscreen_markings() {
  union() {
    translate([board_L*0.05, board_W*0.22, board_T/2 + silk_t/2 - overlap]) silk_rect_base();
    translate([board_L*0.05, board_W*0.05, board_T/2 + silk_t/2 - overlap]) silk_line_base();
  }
}

module connectors() {
  union() {
    translate([-board_L/2 + conn_body_L/2 - overlap, 0, board_T/2 + conn_body_H/2 - overlap]) connector_body_base();
    translate([-board_L/2 + pin_L/2 - overlap, -1.5*pin_pitch, board_T/2 + pin_H/2 - overlap]) connector_pin_base();
    translate([-board_L/2 + pin_L/2 - overlap, -0.5*pin_pitch, board_T/2 + pin_H/2 - overlap]) connector_pin_base();
    translate([-board_L/2 + pin_L/2 - overlap, 0.5*pin_pitch, board_T/2 + pin_H/2 - overlap]) connector_pin_base();
    translate([-board_L/2 + pin_L/2 - overlap, 1.5*pin_pitch, board_T/2 + pin_H/2 - overlap]) connector_pin_base();
  }
}

module sensor_package_components() {
  union() {
    translate([board_L*0.18, board_W*0.05, board_T/2 + sensor_body_H/2 - overlap]) sensor_body_base();
    translate([board_L*0.18, board_W*0.05, board_T/2 + sensor_body_H - overlap + sensor_cap_h/2]) sensor_cap_base();
  }
}

// Final Assembly
module pcb_assembly_union() {
  union() {
    color([0.0, 0.4, 0.2]) pcb_main_board(); // PCB color
    color([0.72, 0.45, 0.2]) copper_pads(); // Copper pads color
    color([0.85, 0.85, 0.8]) silkscreen_markings(); // Silkscreen color
    color([0.15, 0.2, 0.35]) connectors(); // Connectors color
    color([0.15, 0.2, 0.35]) sensor_package_components(); // Sensor package color
  }
}

// Render the final assembly
pcb_assembly_union();