// Dimension-calibrated (target: 26.42 x 26.42 x 5.59 mm)
scale([0.851635, 0.847639, 0.541224])
{
// Parameters
bbox_x = 26.42; //[13.21:52.84:0.01]
bbox_y = 26.42; //[13.21:52.84:0.01]
thickness_z = 5.59; //[2.8:11.18:0.01]
core_size = 10.0; //[5.0:20.0:0.1]
arm_width = 8.0; //[4.0:16.0:0.1]
corner_radius = 2.0; //[0.5:4.0:0.1]
arm_length = 8.21; //[4.105:16.42:0.01]
overlap = 0.8; //[0.2:2.0:0.1]
fillet_r_z = 0.6; //[0.2:1.5:0.1]

// Base shapes
module central_core_region() {
  cube([core_size, core_size, thickness_z], center=true);
}

module arm_pos_x() {
  translate([core_size/2 + (arm_length + overlap)/2 - overlap, 0, 0])
    cube([arm_length + overlap, arm_width, thickness_z], center=true);
}

module arm_neg_x() {
  translate([-(core_size/2 + (arm_length + overlap)/2 - overlap), 0, 0])
    cube([arm_length + overlap, arm_width, thickness_z], center=true);
}

module arm_pos_y() {
  translate([0, core_size/2 + (arm_length + overlap)/2 - overlap, 0])
    cube([arm_width, arm_length + overlap, thickness_z], center=true);
}

module arm_neg_y() {
  translate([0, -(core_size/2 + (arm_length + overlap)/2 - overlap), 0])
    cube([arm_width, arm_length + overlap, thickness_z], center=true);
}

module outer_corner_rounding() {
  sphere(r=corner_radius, center=true);
}

module edge_fillet_top_bottom() {
  sphere(r=fillet_r_z, center=true);
}

module surface_markings() {
  cube([overlap, overlap, overlap], center=true);
}

// Operations
module four_arms() {
  union() {
    arm_pos_x();
    arm_neg_x();
    arm_pos_y();
    arm_neg_y();
  }
}

module cross_footprint_2d() {
  union() {
    central_core_region();
    four_arms();
  }
}

module extruded_body() {
  minkowski() {
    cross_footprint_2d();
    outer_corner_rounding();
  }
}

module final_cross_with_edge_fillet() {
  minkowski() {
    extruded_body();
    edge_fillet_top_bottom();
  }
}

module complete_model() {
  union() {
    final_cross_with_edge_fillet();
    surface_markings();
  }
}

// Final output
complete_model();
}
