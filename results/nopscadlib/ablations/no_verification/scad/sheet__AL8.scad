// Parameters
plate_L = 300; //[150:600:1]
plate_W = 200; //[100:400:1]
plate_T = 12; //[6:24:1]
edge_chamfer = 0.5; //[0.25:2:0.25]
corner_radius = 6; //[3:12:1]
hole_d = 10; //[5:20:0.5]
hole_edge_margin = 25; //[12:50:1]
hole_count_x = 3; //[2:6:1]
hole_count_y = 2; //[2:5:1]
hole_pitch_x = 125; //[50:250:1]
hole_pitch_y = 150; //[50:250:1]
overlap = 1; //[0.5:2:0.5]
marking_depth = 0.2; //[0.1:1:0.1]
marking_L = 60; //[20:120:1]
marking_W = 30; //[10:80:1]

// Base shapes
module tooling_plate_body() {
  color("Silver")
  cube([plate_L, plate_W, plate_T], center=true);
}

module corner_cut_tr() {
  translate([plate_L/2 - corner_radius, plate_W/2 - corner_radius, 0])
  cube([corner_radius*2, corner_radius*2, plate_T + overlap*2], center=true);
}

module corner_round_tr() {
  translate([plate_L/2 - corner_radius, plate_W/2 - corner_radius, 0])
  cylinder(r=corner_radius, h=plate_T + overlap*2, center=true);
}

module corner_cut_tl() {
  translate([-plate_L/2 + corner_radius, plate_W/2 - corner_radius, 0])
  cube([corner_radius*2, corner_radius*2, plate_T + overlap*2], center=true);
}

module corner_round_tl() {
  translate([-plate_L/2 + corner_radius, plate_W/2 - corner_radius, 0])
  cylinder(r=corner_radius, h=plate_T + overlap*2, center=true);
}

module corner_cut_br() {
  translate([plate_L/2 - corner_radius, -plate_W/2 + corner_radius, 0])
  cube([corner_radius*2, corner_radius*2, plate_T + overlap*2], center=true);
}

module corner_round_br() {
  translate([plate_L/2 - corner_radius, -plate_W/2 + corner_radius, 0])
  cylinder(r=corner_radius, h=plate_T + overlap*2, center=true);
}

module corner_cut_bl() {
  translate([-plate_L/2 + corner_radius, -plate_W/2 + corner_radius, 0])
  cube([corner_radius*2, corner_radius*2, plate_T + overlap*2], center=true);
}

module corner_round_bl() {
  translate([-plate_L/2 + corner_radius, -plate_W/2 + corner_radius, 0])
  cylinder(r=corner_radius, h=plate_T + overlap*2, center=true);
}

module chamfer_wedge_x_pos() {
  translate([plate_L/2 - edge_chamfer, 0, plate_T/2 - edge_chamfer])
  rotate([0, 45, 0])
  cube([edge_chamfer*2, plate_W + overlap*2, edge_chamfer*2], center=true);
}

module chamfer_wedge_x_neg() {
  translate([-plate_L/2 + edge_chamfer, 0, plate_T/2 - edge_chamfer])
  rotate([0, -45, 0])
  cube([edge_chamfer*2, plate_W + overlap*2, edge_chamfer*2], center=true);
}

module chamfer_wedge_y_pos() {
  translate([0, plate_W/2 - edge_chamfer, plate_T/2 - edge_chamfer])
  rotate([45, 0, 0])
  cube([plate_L + overlap*2, edge_chamfer*2, edge_chamfer*2], center=true);
}

module chamfer_wedge_y_neg() {
  translate([0, -plate_W/2 + edge_chamfer, plate_T/2 - edge_chamfer])
  rotate([-45, 0, 0])
  cube([plate_L + overlap*2, edge_chamfer*2, edge_chamfer*2], center=true);
}

module mounting_hole(x, y) {
  translate([x, y, 0])
  cylinder(r=hole_d/2, h=plate_T + overlap*2, center=true);
}

module surface_marking_or_label() {
  translate([0, 0, plate_T/2 - marking_depth/2])
  cube([marking_L, marking_W, marking_depth + overlap], center=true);
}

// Operations
module corner_radius_tr() {
  difference() {
    corner_cut_tr();
    corner_round_tr();
  }
}

module corner_radius_tl() {
  difference() {
    corner_cut_tl();
    corner_round_tl();
  }
}

module corner_radius_br() {
  difference() {
    corner_cut_br();
    corner_round_br();
  }
}

module corner_radius_bl() {
  difference() {
    corner_cut_bl();
    corner_round_bl();
  }
}

module tooling_plate_with_corner_radius() {
  difference() {
    tooling_plate_body();
    corner_radius_tr();
    corner_radius_tl();
    corner_radius_br();
    corner_radius_bl();
  }
}

module edge_chamfer_or_round() {
  difference() {
    tooling_plate_with_corner_radius();
    chamfer_wedge_x_pos();
    chamfer_wedge_x_neg();
    chamfer_wedge_y_pos();
    chamfer_wedge_y_neg();
  }
}

module mounting_holes_pattern() {
  difference() {
    edge_chamfer_or_round();
    for (x = [-hole_pitch_x, 0, hole_pitch_x])
      for (y = [-hole_pitch_y/2, hole_pitch_y/2])
        mounting_hole(x, y);
  }
}

module final_tooling_plate() {
  difference() {
    mounting_holes_pattern();
    surface_marking_or_label();
  }
}

// Final output
final_tooling_plate();