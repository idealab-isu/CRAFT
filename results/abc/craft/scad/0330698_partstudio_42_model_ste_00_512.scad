// Dimension-calibrated (target: 0.06 x 0.10 x 0.01 mm)
scale([1.051083, 1.029671, 0.453066])
{
// Parameters
bbox_X = 0.06; //[0.03:0.12:0.001]
bbox_Y = 0.1; //[0.05:0.2:0.001]
T = 0.01; //[0.005:0.02:0.001]
outline_margin = 0.002; //[0.001:0.004:0.0005]
step_inset_1 = 0.006; //[0.003:0.012:0.001]
step_inset_2 = 0.01; //[0.005:0.02:0.001]
corner_r = 0.003; //[0.0015:0.006:0.0005]
corner_ch = 0.002; //[0.001:0.004:0.0005]
edge_break_r = 0.0006; //[0.0002:0.0012:0.0001]
hole_sq = 0.008; //[0.004:0.016:0.001]
hole_rot_deg = 45; //[0:90:1]
hole_group_dx = 0.02; //[0.01:0.04:0.001]
hole_group_dy = 0.028; //[0.014:0.056:0.001]
hole_pitch_y = 0.014; //[0.007:0.028:0.001]
hole_pitch_x = 0.01; //[0.005:0.02:0.001]
hole_center_offset_x = 0.0; //[-0.01:0.01:0.001]
hole_center_offset_y = 0.0; //[-0.01:0.01:0.001]
hole_clear_z = 0.002; //[0.001:0.004:0.0005]
overlap = 0.001; //[0.0005:0.002:0.0005]

// Base Shapes
module plate_main_profile() {
  linear_extrude(height=T, center=true) {
    polygon(points=[
      [-bbox_X/2 + outline_margin + corner_ch, -bbox_Y/2 + outline_margin],
      [bbox_X/2 - outline_margin - step_inset_1, -bbox_Y/2 + outline_margin],
      [bbox_X/2 - outline_margin, -bbox_Y/2 + outline_margin + step_inset_1],
      [bbox_X/2 - outline_margin, -bbox_Y/2 + outline_margin + bbox_Y*0.28],
      [bbox_X/2 - outline_margin - step_inset_2, -bbox_Y/2 + outline_margin + bbox_Y*0.28],
      [bbox_X/2 - outline_margin - step_inset_2, bbox_Y/2 - outline_margin - bbox_Y*0.22],
      [bbox_X/2 - outline_margin, bbox_Y/2 - outline_margin - bbox_Y*0.22],
      [bbox_X/2 - outline_margin, bbox_Y/2 - outline_margin - step_inset_1],
      [bbox_X/2 - outline_margin - step_inset_1, bbox_Y/2 - outline_margin],
      [-bbox_X/2 + outline_margin + step_inset_2, bbox_Y/2 - outline_margin],
      [-bbox_X/2 + outline_margin, bbox_Y/2 - outline_margin - step_inset_2],
      [-bbox_X/2 + outline_margin, bbox_Y/2 - outline_margin - bbox_Y*0.35],
      [-bbox_X/2 + outline_margin + step_inset_1, bbox_Y/2 - outline_margin - bbox_Y*0.35],
      [-bbox_X/2 + outline_margin + step_inset_1, -bbox_Y/2 + outline_margin + bbox_Y*0.18],
      [-bbox_X/2 + outline_margin, -bbox_Y/2 + outline_margin + bbox_Y*0.18],
      [-bbox_X/2 + outline_margin, -bbox_Y/2 + outline_margin + corner_ch]
    ]);
  }
}

module stepped_outline_segments() {
  linear_extrude(height=T, center=true) {
    polygon(points=[
      [bbox_X/2 - outline_margin - step_inset_1, -bbox_Y/2 + outline_margin],
      [bbox_X/2 - outline_margin, -bbox_Y/2 + outline_margin + step_inset_1],
      [bbox_X/2 - outline_margin, -bbox_Y/2 + outline_margin + bbox_Y*0.28],
      [bbox_X/2 - outline_margin - step_inset_2, -bbox_Y/2 + outline_margin + bbox_Y*0.28],
      [bbox_X/2 - outline_margin - step_inset_2, bbox_Y/2 - outline_margin - bbox_Y*0.22],
      [bbox_X/2 - outline_margin, bbox_Y/2 - outline_margin - bbox_Y*0.22],
      [bbox_X/2 - outline_margin, bbox_Y/2 - outline_margin - step_inset_1],
      [bbox_X/2 - outline_margin - step_inset_1, bbox_Y/2 - outline_margin],
      [-bbox_X/2 + outline_margin + step_inset_2, bbox_Y/2 - outline_margin],
      [-bbox_X/2 + outline_margin, bbox_Y/2 - outline_margin - step_inset_2],
      [-bbox_X/2 + outline_margin, bbox_Y/2 - outline_margin - bbox_Y*0.35],
      [-bbox_X/2 + outline_margin + step_inset_1, bbox_Y/2 - outline_margin - bbox_Y*0.35],
      [-bbox_X/2 + outline_margin + step_inset_1, -bbox_Y/2 + outline_margin + bbox_Y*0.18],
      [-bbox_X/2 + outline_margin, -bbox_Y/2 + outline_margin + bbox_Y*0.18],
      [-bbox_X/2 + outline_margin, -bbox_Y/2 + outline_margin]
    ]);
  }
}

module corner_rounds_or_chamfers() {
  linear_extrude(height=T, center=true) {
    polygon(points=[
      [-bbox_X/2 + outline_margin, -bbox_Y/2 + outline_margin],
      [-bbox_X/2 + outline_margin + corner_ch, -bbox_Y/2 + outline_margin],
      [-bbox_X/2 + outline_margin, -bbox_Y/2 + outline_margin + corner_ch]
    ]);
  }
}

module mixed_corner_treatments_per_corner() {
  linear_extrude(height=T, center=true) {
    polygon(points=[
      [bbox_X/2 - outline_margin, bbox_Y/2 - outline_margin],
      [bbox_X/2 - outline_margin - corner_ch, bbox_Y/2 - outline_margin],
      [bbox_X/2 - outline_margin, bbox_Y/2 - outline_margin - corner_ch]
    ]);
  }
}

module through_hole(position_x, position_y) {
  rotate([0, 0, hole_rot_deg]) {
    translate([position_x, position_y, 0]) {
      cube([hole_sq, hole_sq, T + hole_clear_z], center=true);
    }
  }
}

module small_edge_break_chamfer() {
  sphere(r=edge_break_r, center=true);
}

module hole_edge_chamfer_or_countersink_suggestion() {
  cylinder(h=T, r1=hole_sq/2, r2=0, center=true);
}

// Operations
module plate_minus_corner_chamfers() {
  difference() {
    plate_main_profile();
    corner_rounds_or_chamfers();
    mixed_corner_treatments_per_corner();
  }
}

module plate_with_edge_break() {
  minkowski() {
    plate_minus_corner_chamfers();
    small_edge_break_chamfer();
  }
}

module plate_with_steps_and_edge_break() {
  union() {
    plate_with_edge_break();
    stepped_outline_segments();
  }
}

module plate_with_holes() {
  difference() {
    plate_with_steps_and_edge_break();
    through_hole(-hole_group_dx/2 - hole_pitch_x/2 + hole_center_offset_x, -hole_group_dy/2 - hole_pitch_y + hole_center_offset_y);
    through_hole(-hole_group_dx/2 + hole_center_offset_x, -hole_group_dy/2 + hole_center_offset_y);
    through_hole(-hole_group_dx/2 + hole_pitch_x/2 + hole_center_offset_x, -hole_group_dy/2 + hole_pitch_y + hole_center_offset_y);
    through_hole(hole_group_dx/2 - hole_pitch_x/2 + hole_center_offset_x, hole_group_dy/2 - hole_pitch_y + hole_center_offset_y);
    through_hole(hole_group_dx/2 + hole_center_offset_x, hole_group_dy/2 + hole_center_offset_y);
    through_hole(hole_group_dx/2 + hole_pitch_x/2 + hole_center_offset_x, hole_group_dy/2 + hole_pitch_y + hole_center_offset_y);
  }
}

module final_model() {
  union() {
    plate_with_holes();
    hole_edge_chamfer_or_countersink_suggestion();
  }
}

// Final Output
final_model();
}
