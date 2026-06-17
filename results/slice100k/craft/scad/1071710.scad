// Dimension-calibrated (target: 10.97 x 43.93 x 10.92 mm)
scale([0.972265, 0.906098, 1.535292])
{
// Parameters
L_total = 43.93; //[21.97:87.86:0.01]
W_max = 10.97; //[5.49:21.94:0.01]
H_max = 10.92; //[5.46:21.84:0.01]
t = 1.2; //[0.6:2.4:0.05]
pad_L = 12.0; //[6.0:24.0:0.1]
pad_W = 10.97; //[5.49:21.94:0.01]
arm_L = 15.965; //[7.98:31.93:0.01]
arm_W = 8.0; //[4.0:16.0:0.1]
arm_angle_deg = 18.0; //[5.0:35.0:0.5]
blend_R = 6.0; //[3.0:12.0:0.1]
small_fillet_r = 0.6; //[0.3:1.2:0.05]
tip_round_r = 1.2; //[0.6:2.4:0.05]
overlap = 1.0; //[0.5:2.0:0.1]
blend_span_x = 6.0; //[3.0:12.0:0.1]

// Base Shapes
module central_pad() {
  translate([0, 0, 0])
    cube([pad_L, pad_W, t], center=true);
}

module arm_left_raw() {
  translate([0, 0, 0])
    cube([arm_L, arm_W, t], center=true);
}

module arm_right_raw() {
  translate([0, 0, 0])
    cube([arm_L, arm_W, t], center=true);
}

module blend_left_pad_stub() {
  translate([0, 0, 0])
    cube([blend_span_x, arm_W, t], center=true);
}

module blend_left_arm_stub() {
  translate([0, 0, 0])
    cube([blend_span_x, arm_W, t], center=true);
}

module blend_right_pad_stub() {
  translate([0, 0, 0])
    cube([blend_span_x, arm_W, t], center=true);
}

module blend_right_arm_stub() {
  translate([0, 0, 0])
    cube([blend_span_x, arm_W, t], center=true);
}

module tip_round_sphere() {
  sphere(r=tip_round_r, center=true);
}

module small_fillet_sphere() {
  sphere(r=small_fillet_r, center=true);
}

// Operations
module arm_left_bent() {
  rotate([0, arm_angle_deg, 0])
    arm_left_raw();
}

module arm_left() {
  translate([-(pad_L/2 + arm_L/2 - overlap), 0, 0])
    arm_left_bent();
}

module arm_right_bent() {
  rotate([0, -arm_angle_deg, 0])
    arm_right_raw();
}

module arm_right() {
  translate([(pad_L/2 + arm_L/2 - overlap), 0, 0])
    arm_right_bent();
}

module blend_left_pad_stub_pos() {
  translate([-(pad_L/2 - blend_span_x/2), 0, 0])
    blend_left_pad_stub();
}

module blend_left_arm_stub_rot() {
  rotate([0, arm_angle_deg, 0])
    blend_left_arm_stub();
}

module blend_left_arm_stub_pos() {
  translate([-(pad_L/2 + blend_span_x/2 - overlap), 0, 0])
    blend_left_arm_stub_rot();
}

module large_blend_transitions_pad_to_arms_left() {
  hull() {
    blend_left_pad_stub_pos();
    blend_left_arm_stub_pos();
  }
}

module blend_right_pad_stub_pos() {
  translate([(pad_L/2 - blend_span_x/2), 0, 0])
    blend_right_pad_stub();
}

module blend_right_arm_stub_rot() {
  rotate([0, -arm_angle_deg, 0])
    blend_right_arm_stub();
}

module blend_right_arm_stub_pos() {
  translate([(pad_L/2 + blend_span_x/2 - overlap), 0, 0])
    blend_right_arm_stub_rot();
}

module large_blend_transitions_pad_to_arms_right() {
  hull() {
    blend_right_pad_stub_pos();
    blend_right_arm_stub_pos();
  }
}

module arm_left_tip_sphere_pos() {
  translate([-(pad_L/2 + arm_L - overlap), 0, 0])
    tip_round_sphere();
}

module arm_left_tip_rounding() {
  hull() {
    arm_left();
    arm_left_tip_sphere_pos();
  }
}

module arm_right_tip_sphere_pos() {
  translate([(pad_L/2 + arm_L - overlap), 0, 0])
    tip_round_sphere();
}

module arm_right_tip_rounding() {
  hull() {
    arm_right();
    arm_right_tip_sphere_pos();
  }
}

module constant_thickness_profile() {
  union() {
    central_pad();
    arm_left_tip_rounding();
    arm_right_tip_rounding();
    large_blend_transitions_pad_to_arms_left();
    large_blend_transitions_pad_to_arms_right();
  }
}

module edge_rounding_small_fillets() {
  minkowski() {
    constant_thickness_profile();
    small_fillet_sphere();
  }
}

module arm_angle_bend() {
  union() {
    arm_left();
    arm_right();
  }
}

module large_blend_transitions_pad_to_arms() {
  union() {
    large_blend_transitions_pad_to_arms_left();
    large_blend_transitions_pad_to_arms_right();
  }
}

module slight_end_rounding_on_arm_tips() {
  union() {
    arm_left_tip_rounding();
    arm_right_tip_rounding();
  }
}

module complete_model() {
  union() {
    edge_rounding_small_fillets();
    arm_angle_bend();
    large_blend_transitions_pad_to_arms();
    slight_end_rounding_on_arm_tips();
  }
}

// Final Output
complete_model();
}
