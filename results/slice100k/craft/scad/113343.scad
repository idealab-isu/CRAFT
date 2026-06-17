// Parameters
bbox_X = 36.17; //[18.085:72.34:0.01]
bbox_Y = 55.53; //[27.765:111.06:0.01]
bbox_Z = 8.66; //[4.33:17.32:0.01]
wedge_length_Y = 55.53; //[27.765:111.06:0.01]
wedge_width_X_max = 36.17; //[18.085:72.34:0.01]
wedge_thickness_Z_max = 8.66; //[4.33:17.32:0.01]
tip_width_X_min = 0.6; //[0.3:1.2:0.01]
tip_thickness_Z_min = 0.4; //[0.2:0.8:0.01]
flange_width_X = 3; //[1.5:6:0.01]
flange_step_height_Z = 1.2; //[0.6:2.4:0.01]
flange_length_Y = 50; //[25:100:0.01]
flange_offset_from_wide_end_Y = 2; //[1:4:0.01]
wide_end_endface_depth_Y = 4; //[2:8:0.01]
wide_end_shoulder_height_Z = 2; //[1:4:0.01]
wide_end_shoulder_length_Y = 6; //[3:12:0.01]
connect_overlap = 1; //[0.5:2:0.01]
chamfer_size = 0.6; //[0:1.2:0.01]
fillet_radius = 0.8; //[0:1.6:0.01]

// Base Shapes
module tapered_wedge_main_body() {
  linear_extrude(height=wedge_thickness_Z_max, center=true)
    polygon(points=[
      [-wedge_width_X_max/2, -wedge_length_Y/2],
      [wedge_width_X_max/2, -wedge_length_Y/2],
      [tip_width_X_min/2, wedge_length_Y/2],
      [-tip_width_X_min/2, wedge_length_Y/2]
    ]);
}

module sharp_tip_end() {
  linear_extrude(height=tip_thickness_Z_min, center=true)
    polygon(points=[
      [-tip_width_X_min/2, wedge_length_Y/2 - wide_end_endface_depth_Y],
      [tip_width_X_min/2, wedge_length_Y/2 - wide_end_endface_depth_Y],
      [tip_width_X_min/2, wedge_length_Y/2],
      [-tip_width_X_min/2, wedge_length_Y/2]
    ]);
}

module wide_end_perpendicular_end_face() {
  translate([0, -wedge_length_Y/2 + wide_end_endface_depth_Y/2 - connect_overlap, 0])
    cube([wedge_width_X_max, wide_end_endface_depth_Y, wedge_thickness_Z_max], center=true);
}

module longitudinal_step_flange_along_one_long_edge() {
  translate([wedge_width_X_max/2 - flange_width_X/2 - connect_overlap, -wedge_length_Y/2 + flange_offset_from_wide_end_Y + flange_length_Y/2, wedge_thickness_Z_max/2 - flange_step_height_Z/2 - connect_overlap])
    cube([flange_width_X, flange_length_Y, flange_step_height_Z], center=true);
}

module wide_end_L_profile_shoulder() {
  translate([0, -wedge_length_Y/2 + wide_end_shoulder_length_Y/2 - connect_overlap, wedge_thickness_Z_max/2 - wide_end_shoulder_height_Z/2 - connect_overlap])
    cube([wedge_width_X_max, wide_end_shoulder_length_Y, wide_end_shoulder_height_Z], center=true);
}

module edge_chamfers() {
  cube([wedge_width_X_max + 2*connect_overlap, wedge_length_Y + 2*connect_overlap, chamfer_size], center=true);
}

module edge_fillets() {
  sphere(r=fillet_radius, center=true);
}

module surface_text_or_markings() {
  translate([0, -wedge_length_Y/2 + connect_overlap, wedge_thickness_Z_max/2 - connect_overlap])
    cube([connect_overlap, connect_overlap, connect_overlap], center=true);
}

// Operations
module union_core_with_features() {
  union() {
    tapered_wedge_main_body();
    sharp_tip_end();
    wide_end_perpendicular_end_face();
    longitudinal_step_flange_along_one_long_edge();
    wide_end_L_profile_shoulder();
    surface_text_or_markings();
  }
}

module difference_apply_edge_chamfers() {
  difference() {
    union_core_with_features();
    translate([0, 0, wedge_thickness_Z_max/2 - chamfer_size/2]) edge_chamfers();
    translate([0, 0, -wedge_thickness_Z_max/2 + chamfer_size/2]) edge_chamfers();
  }
}

// Final Output
minkowski() {
  difference_apply_edge_chamfers();
  edge_fillets();
}