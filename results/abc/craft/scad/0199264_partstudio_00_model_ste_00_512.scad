// Dimension-calibrated (target: 0.10 x 0.01 x 0.12 mm)
scale([0.767757, 0.720248, 0.337188])
{
// Parameters
bbox_x = 0.1; //[0.05:0.2:0.001]
bbox_y = 0.01; //[0.005:0.02:0.001]
bbox_z = 0.12; //[0.06:0.24:0.001]
plate_thk = 0.01; //[0.005:0.02:0.001]
hub_r = 0.012; //[0.006:0.024:0.001]
arm_len = 0.04; //[0.02:0.08:0.001]
arm_w_root = 0.01; //[0.005:0.02:0.001]
arm_w_tip = 0.018; //[0.009:0.036:0.001]
pad_len = 0.028; //[0.014:0.056:0.001]
pad_w = 0.024; //[0.012:0.048:0.001]
pad_corner_r = 0.004; //[0.002:0.008:0.001]
hole_count = 3; //[1:5:1]
hole_size = 0.004; //[0.002:0.008:0.001]
hole_pitch = 0.007; //[0.004:0.014:0.001]
hole_edge_margin = 0.004; //[0.002:0.008:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
chamfer_r = 0.0005; //[0.0002:0.001:0.0001]
junction_fillet_r = 0.002; //[0.001:0.004:0.0005]
arm_root_overlap_into_hub = 0.002; //[0.001:0.004:0.0005]

// Base Shapes
module central_hub() {
  cylinder(r=hub_r, h=plate_thk, center=true);
}

module arm_profile_2d() {
  linear_extrude(height=plate_thk, center=true)
    polygon(points=[
      [hub_r - arm_root_overlap_into_hub, -arm_w_root/2],
      [hub_r - arm_root_overlap_into_hub, arm_w_root/2],
      [hub_r + arm_len, arm_w_tip/2],
      [hub_r + arm_len, -arm_w_tip/2]
    ]);
}

module end_pad_rect_2d() {
  linear_extrude(height=plate_thk, center=true)
    square([pad_len - 2*pad_corner_r, pad_w - 2*pad_corner_r], center=true);
}

module pad_corner_round_sphere() {
  sphere(r=pad_corner_r, center=true);
}

module hole_square_prism() {
  linear_extrude(height=plate_thk + 2*overlap, center=true)
    square([hole_size, hole_size], center=true);
}

module junction_sphere() {
  sphere(r=junction_fillet_r, center=true);
}

module chamfer_sphere() {
  sphere(r=chamfer_r, center=true);
}

// Operations
module rounded_corners_on_pads() {
  minkowski() {
    end_pad_rect_2d();
    pad_corner_round_sphere();
  }
}

module end_pad_1_translate() {
  translate([hub_r + arm_len + pad_len/2 - overlap, 0, 0])
    rounded_corners_on_pads();
}

module end_pad_2_rotate() {
  rotate([0, 0, 60])
    end_pad_1_translate();
}

module end_pad_3_rotate() {
  rotate([0, 0, 120])
    end_pad_1_translate();
}

module end_pad_4_rotate() {
  rotate([0, 0, 180])
    end_pad_1_translate();
}

module end_pad_5_rotate() {
  rotate([0, 0, 240])
    end_pad_1_translate();
}

module end_pad_6_rotate() {
  rotate([0, 0, 300])
    end_pad_1_translate();
}

module arm_1_translate() {
  translate([0, 0, 0])
    arm_profile_2d();
}

module arm_2_rotate() {
  rotate([0, 0, 60])
    arm_1_translate();
}

module arm_3_rotate() {
  rotate([0, 0, 120])
    arm_1_translate();
}

module arm_4_rotate() {
  rotate([0, 0, 180])
    arm_1_translate();
}

module arm_5_rotate() {
  rotate([0, 0, 240])
    arm_1_translate();
}

module arm_6_rotate() {
  rotate([0, 0, 300])
    arm_1_translate();
}

module fillet_sphere_hub_side_pos() {
  translate([hub_r - overlap, 0, 0])
    junction_sphere();
}

module fillet_sphere_arm_side_pos() {
  translate([hub_r + arm_root_overlap_into_hub + junction_fillet_r - overlap, 0, 0])
    junction_sphere();
}

module fillets_at_arm_hub_junction_arm1() {
  hull() {
    fillet_sphere_hub_side_pos();
    fillet_sphere_arm_side_pos();
  }
}

module fillets_at_arm_hub_junction_arm2() {
  rotate([0, 0, 60])
    fillets_at_arm_hub_junction_arm1();
}

module fillets_at_arm_hub_junction_arm3() {
  rotate([0, 0, 120])
    fillets_at_arm_hub_junction_arm1();
}

module fillets_at_arm_hub_junction_arm4() {
  rotate([0, 0, 180])
    fillets_at_arm_hub_junction_arm1();
}

module fillets_at_arm_hub_junction_arm5() {
  rotate([0, 0, 240])
    fillets_at_arm_hub_junction_arm1();
}

module fillets_at_arm_hub_junction_arm6() {
  rotate([0, 0, 300])
    fillets_at_arm_hub_junction_arm1();
}

module fillets_at_arm_hub_junction() {
  union() {
    fillets_at_arm_hub_junction_arm1();
    fillets_at_arm_hub_junction_arm2();
    fillets_at_arm_hub_junction_arm3();
    fillets_at_arm_hub_junction_arm4();
    fillets_at_arm_hub_junction_arm5();
    fillets_at_arm_hub_junction_arm6();
  }
}

module plate_without_holes() {
  union() {
    central_hub();
    arm_1_translate();
    arm_2_rotate();
    arm_3_rotate();
    arm_4_rotate();
    arm_5_rotate();
    arm_6_rotate();
    end_pad_1_translate();
    end_pad_2_rotate();
    end_pad_3_rotate();
    end_pad_4_rotate();
    end_pad_5_rotate();
    end_pad_6_rotate();
    fillets_at_arm_hub_junction();
  }
}

module diamond_rotation_of_holes() {
  rotate([0, 0, 45])
    hole_square_prism();
}

module hole_1_pos_on_pad1() {
  translate([hub_r + arm_len + (-pad_len/2 + hole_edge_margin), 0, 0])
    diamond_rotation_of_holes();
}

module hole_2_pos_on_pad1() {
  translate([hub_r + arm_len + (-pad_len/2 + hole_edge_margin + hole_pitch), 0, 0])
    diamond_rotation_of_holes();
}

module hole_3_pos_on_pad1() {
  translate([hub_r + arm_len + (-pad_len/2 + hole_edge_margin + 2*hole_pitch), 0, 0])
    diamond_rotation_of_holes();
}

module through_holes_end_pad_pattern_pad1() {
  union() {
    hole_1_pos_on_pad1();
    hole_2_pos_on_pad1();
    hole_3_pos_on_pad1();
  }
}

module through_holes_end_pad_pattern_pad2() {
  rotate([0, 0, 60])
    through_holes_end_pad_pattern_pad1();
}

module through_holes_end_pad_pattern_pad3() {
  rotate([0, 0, 120])
    through_holes_end_pad_pattern_pad1();
}

module through_holes_end_pad_pattern_pad4() {
  rotate([0, 0, 180])
    through_holes_end_pad_pattern_pad1();
}

module through_holes_end_pad_pattern_pad5() {
  rotate([0, 0, 240])
    through_holes_end_pad_pattern_pad1();
}

module through_holes_end_pad_pattern_pad6() {
  rotate([0, 0, 300])
    through_holes_end_pad_pattern_pad1();
}

module through_holes_end_pad_pattern() {
  union() {
    through_holes_end_pad_pattern_pad1();
    through_holes_end_pad_pattern_pad2();
    through_holes_end_pad_pattern_pad3();
    through_holes_end_pad_pattern_pad4();
    through_holes_end_pad_pattern_pad5();
    through_holes_end_pad_pattern_pad6();
  }
}

module plate_with_holes() {
  difference() {
    plate_without_holes();
    through_holes_end_pad_pattern();
  }
}

module light_chamfer_on_plate_edges() {
  minkowski() {
    plate_with_holes();
    chamfer_sphere();
  }
}

module final_model() {
  union() {
    light_chamfer_on_plate_edges();
  }
}

// Final Output
final_model();
}
