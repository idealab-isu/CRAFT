// Parameters
bbox_L = 0.09; //[0.045:0.18:0.001]
bbox_W = 0.02; //[0.01:0.04:0.001]
bbox_H = 0.06; //[0.03:0.12:0.001]
grip_L = 0.09; //[0.045:0.18:0.001]
grip_W = 0.02; //[0.01:0.04:0.001]
grip_H = 0.02; //[0.01:0.04:0.001]
grip_curve_sag = 0.004; //[0.002:0.008:0.0005]
stem_W = 0.012; //[0.006:0.024:0.001]
stem_D = 0.012; //[0.006:0.024:0.001]
stem_H = 0.032; //[0.016:0.064:0.001]
base_flange_D = 0.018; //[0.009:0.036:0.001]
base_flange_H = 0.006; //[0.003:0.012:0.001]
base_cap_D = 0.014; //[0.007:0.028:0.001]
base_cap_H = 0.004; //[0.002:0.008:0.001]
gusset_L = 0.012; //[0.006:0.024:0.001]
gusset_drop = 0.008; //[0.004:0.016:0.001]
diamond_W = 0.01; //[0.005:0.02:0.001]
diamond_H = 0.01; //[0.005:0.02:0.001]
diamond_depth = 0.0015; //[0.0005:0.003:0.0001]
overlap = 0.001; //[0.0005:0.002:0.0001]
chamfer = 0.001; //[0.0005:0.002:0.0001]
micro_fillet_r = 0.0006; //[0.0003:0.0012:0.0001]

// Base Shapes
module grip_bar_center_block() {
  translate([0, 0, bbox_H/2 - grip_H/2])
    cube([grip_L - 2*gusset_L, grip_W, grip_H], center=true);
}

module grip_bar_left_end_block() {
  translate([-(grip_L/2 - gusset_L/2), 0, bbox_H/2 - grip_H/2 - grip_curve_sag])
    cube([gusset_L, grip_W, grip_H], center=true);
}

module grip_bar_right_end_block() {
  translate([(grip_L/2 - gusset_L/2), 0, bbox_H/2 - grip_H/2 - grip_curve_sag])
    cube([gusset_L, grip_W, grip_H], center=true);
}

module vertical_stem() {
  translate([0, 0, bbox_H/2 - grip_H - stem_H/2 + overlap])
    cube([stem_W, stem_D, stem_H], center=true);
}

module flanged_base_cap_flange() {
  translate([0, 0, bbox_H/2 - grip_H - stem_H - base_flange_H/2 + overlap])
    cylinder(r=base_flange_D/2, h=base_flange_H, center=true);
}

module flanged_base_cap_cap() {
  translate([0, 0, bbox_H/2 - grip_H - stem_H - base_flange_H - base_cap_H/2 + overlap])
    cylinder(r=base_cap_D/2, h=base_cap_H, center=true);
}

module stem_to_grip_faceted_gusset_front() {
  translate([0, 0, bbox_H/2 - grip_H - gusset_drop/2 + overlap])
    cube([gusset_L, stem_D, gusset_drop], center=true);
}

module stem_to_grip_faceted_gusset_left() {
  translate([-(stem_W/2 + gusset_L/2 - overlap), 0, bbox_H/2 - grip_H - gusset_drop/2 + overlap])
    cube([gusset_L, stem_D, gusset_drop], center=true);
}

module stem_to_grip_faceted_gusset_right() {
  translate([(stem_W/2 + gusset_L/2 - overlap), 0, bbox_H/2 - grip_H - gusset_drop/2 + overlap])
    cube([gusset_L, stem_D, gusset_drop], center=true);
}

module diamond_side_recess_left() {
  translate([0, -(grip_W/2 - diamond_depth/2 + overlap), bbox_H/2 - grip_H/2])
    rotate([90, 0, 0])
    linear_extrude(height=diamond_depth, center=true)
      polygon(points=[[0, diamond_H/2], [diamond_W/2, 0], [0, -diamond_H/2], [-diamond_W/2, 0]]);
}

module diamond_side_recess_right() {
  translate([0, (grip_W/2 - diamond_depth/2 + overlap), bbox_H/2 - grip_H/2])
    rotate([-90, 0, 0])
    linear_extrude(height=diamond_depth, center=true)
      polygon(points=[[0, diamond_H/2], [diamond_W/2, 0], [0, -diamond_H/2], [-diamond_W/2, 0]]);
}

module edge_chamfers_top_wedge() {
  translate([0, 0, bbox_H/2 - chamfer/2 + overlap])
    cube([grip_L + 2*overlap, grip_W + 2*overlap, chamfer], center=true);
}

module edge_chamfers_bottom_wedge() {
  translate([0, 0, bbox_H/2 - grip_H - chamfer/2 - overlap])
    cube([grip_L + 2*overlap, grip_W + 2*overlap, chamfer], center=true);
}

module extra_faceting_detail() {
  translate([0, 0, bbox_H/2 - grip_H - stem_H/2 + overlap])
    rotate([0, 0, 45])
    cube([stem_W + 2*chamfer, stem_D + 2*chamfer, stem_H/3], center=true);
}

module micro_fillet_approximations_sphere() {
  sphere(r=micro_fillet_r, center=true);
}

// Operations
module grip_curvature_profile() {
  hull() {
    grip_bar_center_block();
    grip_bar_left_end_block();
    grip_bar_right_end_block();
  }
}

module grip_bar() {
  union() {
    grip_curvature_profile();
    grip_bar_center_block();
  }
}

module stem_to_grip_faceted_gussets() {
  union() {
    stem_to_grip_faceted_gusset_front();
    stem_to_grip_faceted_gusset_left();
    stem_to_grip_faceted_gusset_right();
  }
}

module flanged_base_cap() {
  union() {
    flanged_base_cap_flange();
    flanged_base_cap_cap();
  }
}

module t_handle_raw_union() {
  union() {
    grip_bar();
    vertical_stem();
    stem_to_grip_faceted_gussets();
    flanged_base_cap();
    extra_faceting_detail();
  }
}

module t_handle_with_diamond_recesses() {
  difference() {
    t_handle_raw_union();
    diamond_side_recess_left();
    diamond_side_recess_right();
  }
}

module t_handle_with_edge_chamfers() {
  difference() {
    t_handle_with_diamond_recesses();
    edge_chamfers_top_wedge();
    edge_chamfers_bottom_wedge();
  }
}

// Final Output
minkowski() {
  t_handle_with_edge_chamfers();
  micro_fillet_approximations_sphere();
}