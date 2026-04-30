// Parameters
servo_L = 23.0; //[11.5:46.0:0.1]
servo_W = 12.5; //[6.25:25.0:0.1]
servo_H = 23.0; //[11.5:46.0:0.1]
clearance = 0.4; //[0.2:1.2:0.05]
wall_t = 3.0; //[1.5:6.0:0.1]
base_t = 3.0; //[1.5:6.0:0.1]
bracket_L = 30.0; //[15.0:60.0:0.1]
bracket_W = 22.0; //[11.0:44.0:0.1]
bracket_H = 28.0; //[14.0:56.0:0.1]
horn_slot_L = 18.0; //[9.0:36.0:0.1]
horn_slot_W = 6.0; //[3.0:12.0:0.1]
horn_slot_offset_Z = 18.0; //[9.0:36.0:0.1]
mount_hole_d = 3.2; //[2.0:6.4:0.05]
mount_hole_spacing_Z = 16.0; //[8.0:32.0:0.1]
mount_hole_edge_margin = 4.0; //[2.0:8.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
countersink_d = 6.4; //[4.0:12.0:0.1]
countersink_depth = 2.0; //[1.0:4.0:0.1]
cable_notch_W = 8.0; //[4.0:16.0:0.1]
cable_notch_H = 6.0; //[3.0:12.0:0.1]
tab_L = 4.0; //[2.0:8.0:0.1]
tab_W = 2.5; //[1.0:5.0:0.1]
tab_H = 6.0; //[3.0:12.0:0.1]
lighten_hole_d = 8.0; //[4.0:16.0:0.1]

// Base shapes
module base_plate() {
  translate([0, 0, base_t/2])
    cube([bracket_L, bracket_W, base_t], center=true);
}

module side_wall_left() {
  translate([0, -bracket_W/2 + wall_t/2, bracket_H/2])
    cube([bracket_L, wall_t, bracket_H], center=true);
}

module side_wall_right() {
  translate([0, bracket_W/2 - wall_t/2, bracket_H/2])
    cube([bracket_L, wall_t, bracket_H], center=true);
}

module servo_body_cavity() {
  translate([0, 0, base_t + (servo_H + 2*clearance)/2])
    cube([servo_L + 2*clearance, servo_W + 2*clearance, servo_H + 2*clearance], center=true);
}

module horn_slot_opening() {
  translate([bracket_L/2 - horn_slot_L/2 + overlap, 0, horn_slot_offset_Z])
    cube([horn_slot_L, horn_slot_W, bracket_H], center=true);
}

module mount_hole_cyl() {
  rotate([90, 0, 0])
    cylinder(r=mount_hole_d/2, h=wall_t + 2*overlap, center=true);
}

module countersink_cyl() {
  rotate([90, 0, 0])
    cylinder(r=countersink_d/2, h=countersink_depth + overlap, center=true);
}

module lighten_cyl() {
  rotate([90, 0, 0])
    cylinder(r=lighten_hole_d/2, h=wall_t + 2*overlap, center=true);
}

module cable_exit_notch() {
  translate([0, 0, base_t + cable_notch_H/2])
    cube([bracket_L, cable_notch_W, cable_notch_H], center=true);
}

module anti_rotation_tab_left() {
  translate([-(servo_L + 2*clearance)/2 + tab_L/2 - overlap, -(servo_W + 2*clearance)/2 + tab_W/2 - overlap, base_t + tab_H/2])
    cube([tab_L, tab_W, tab_H], center=true);
}

module anti_rotation_tab_right() {
  translate([-(servo_L + 2*clearance)/2 + tab_L/2 - overlap, (servo_W + 2*clearance)/2 - tab_W/2 + overlap, base_t + tab_H/2])
    cube([tab_L, tab_W, tab_H], center=true);
}

module chamfer_wedge_left() {
  translate([0, -bracket_W/2 + wall_t/2, base_t + wall_t/2])
    rotate([45, 0, 0])
    cube([bracket_L, wall_t, wall_t], center=true);
}

module chamfer_wedge_right() {
  translate([0, bracket_W/2 - wall_t/2, base_t + wall_t/2])
    rotate([-45, 0, 0])
    cube([bracket_L, wall_t, wall_t], center=true);
}

// Operations
module servo_cradle_u_frame() {
  union() {
    base_plate();
    side_wall_left();
    side_wall_right();
    anti_rotation_tab_left();
    anti_rotation_tab_right();
  }
}

module side_mounting_holes_left() {
  union() {
    translate([0, -bracket_W/2 + wall_t/2, bracket_H - mount_hole_edge_margin]) mount_hole_cyl();
    translate([0, -bracket_W/2 + wall_t/2, bracket_H - mount_hole_edge_margin - mount_hole_spacing_Z]) mount_hole_cyl();
  }
}

module side_mounting_holes_right() {
  union() {
    translate([0, bracket_W/2 - wall_t/2, bracket_H - mount_hole_edge_margin]) mount_hole_cyl();
    translate([0, bracket_W/2 - wall_t/2, bracket_H - mount_hole_edge_margin - mount_hole_spacing_Z]) mount_hole_cyl();
  }
}

module countersinks_counterbores() {
  union() {
    translate([0, -bracket_W/2 + wall_t/2, bracket_H - mount_hole_edge_margin]) countersink_cyl();
    translate([0, -bracket_W/2 + wall_t/2, bracket_H - mount_hole_edge_margin - mount_hole_spacing_Z]) countersink_cyl();
    translate([0, bracket_W/2 - wall_t/2, bracket_H - mount_hole_edge_margin]) countersink_cyl();
    translate([0, bracket_W/2 - wall_t/2, bracket_H - mount_hole_edge_margin - mount_hole_spacing_Z]) countersink_cyl();
  }
}

module lightening_cutouts() {
  union() {
    translate([0, -bracket_W/2 + wall_t/2, base_t + (bracket_H - base_t)/2]) lighten_cyl();
    translate([0, bracket_W/2 - wall_t/2, base_t + (bracket_H - base_t)/2]) lighten_cyl();
  }
}

module fillets_chamfers() {
  union() {
    chamfer_wedge_left();
    chamfer_wedge_right();
  }
}

module bracket_with_chamfers_removed() {
  difference() {
    servo_cradle_u_frame();
    fillets_chamfers();
  }
}

module bracket_main_openings() {
  difference() {
    bracket_with_chamfers_removed();
    servo_body_cavity();
    horn_slot_opening();
    cable_exit_notch();
    side_mounting_holes_left();
    side_mounting_holes_right();
    countersinks_counterbores();
    lightening_cutouts();
  }
}

module complete_model() {
  union() {
    bracket_main_openings();
    anti_rotation_tab_left();
    anti_rotation_tab_right();
  }
}

// Final output
complete_model();