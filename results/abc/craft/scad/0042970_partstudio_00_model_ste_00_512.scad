// Dimension-calibrated (target: 0.07 x 0.18 x 0.02 mm)
scale([1.000000, 0.971429, 0.619850])
{
// Parameters
L = 0.18; //[0.09:0.36:0.001]
W = 0.07; //[0.035:0.14:0.001]
T = 0.02; //[0.01:0.04:0.001]
frame_wall = 0.008; //[0.004:0.016:0.001]
cutout_L = 0.14; //[0.07:0.28:0.001]
cutout_W = 0.04; //[0.02:0.08:0.001]
end_loop_R = 0.015; //[0.0075:0.03:0.0005]
pad_L = 0.022; //[0.011:0.044:0.001]
pad_W = 0.016; //[0.008:0.032:0.001]
pad_H = 0.006; //[0.003:0.012:0.001]
pad_inset_x = 0.02; //[0.01:0.04:0.001]
pad_inset_y = 0.012; //[0.006:0.024:0.001]
pad_angle_deg = 20; //[0:45:1]
hole_d = 0.004; //[0.002:0.008:0.0005]
hole_pitch = 0.01; //[0.005:0.02:0.0005]
hole_edge_margin = 0.004; //[0.002:0.008:0.0005]
rib_H = 0.003; //[0.0015:0.006:0.0005]
rib_W = 0.003; //[0.0015:0.006:0.0005]
rib_L = 0.016; //[0.008:0.032:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
chamfer_depth = 0.001; //[0.0005:0.002:0.0005]
relief_depth = 0.002; //[0.001:0.004:0.0005]
relief_margin = 0.002; //[0.001:0.004:0.0005]

// Base Shapes
module outer_frame_plate() {
  cube([L, W, T], center=true);
}

module central_clearance_cutout() {
  cube([cutout_L, cutout_W, T + 2*overlap], center=true);
}

module end_loops_rounded_ends() {
  rotate([90, 0, 0])
    cylinder(r=end_loop_R, h=T, center=true);
}

module mounting_pad() {
  cube([pad_L, pad_W, pad_H], center=true);
}

module pad_holes() {
  cylinder(r=hole_d/2, h=T + pad_H + 2*overlap, center=true);
}

module pad_ribs() {
  cube([rib_L, rib_W, rib_H], center=true);
}

module chamfer_hole_entries() {
  cylinder(r1=hole_d/2 + chamfer_depth, r2=hole_d/2, h=chamfer_depth, center=true);
}

module lightening_reliefs_on_pads() {
  cube([pad_L - 2*relief_margin, pad_W - 2*relief_margin, relief_depth + 2*overlap], center=true);
}

module surface_text_or_markings() {
  cube([overlap, overlap, overlap], center=true);
}

// Operations
module frame_minus_cutout() {
  difference() {
    outer_frame_plate();
    central_clearance_cutout();
  }
}

module frame_with_end_loops() {
  union() {
    frame_minus_cutout();
    translate([-L/2 + end_loop_R, 0, 0]) end_loops_rounded_ends();
    translate([L/2 - end_loop_R, 0, 0]) end_loops_rounded_ends();
  }
}

module frame_with_pads() {
  union() {
    frame_with_end_loops();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H/2 - overlap])
      rotate([0, 0, pad_angle_deg]) mounting_pad();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H/2 - overlap])
      rotate([0, 0, -pad_angle_deg]) mounting_pad();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H/2 - overlap])
      rotate([0, 0, -pad_angle_deg]) mounting_pad();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H/2 - overlap])
      rotate([0, 0, pad_angle_deg]) mounting_pad();
  }
}

module all_pad_holes() {
  union() {
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap - hole_pitch/2, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H/2 - overlap])
      pad_holes();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap + hole_pitch/2, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H/2 - overlap])
      pad_holes();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap - hole_pitch/2, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H/2 - overlap])
      pad_holes();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap + hole_pitch/2, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H/2 - overlap])
      pad_holes();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap - hole_pitch/2, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H/2 - overlap])
      pad_holes();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap + hole_pitch/2, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H/2 - overlap])
      pad_holes();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap - hole_pitch/2, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H/2 - overlap])
      pad_holes();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap + hole_pitch/2, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H/2 - overlap])
      pad_holes();
  }
}

module frame_pads_ribs() {
  union() {
    frame_with_pads();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H - overlap + rib_H/2])
      rotate([0, 0, pad_angle_deg]) pad_ribs();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H - overlap + rib_H/2])
      rotate([0, 0, -pad_angle_deg]) pad_ribs();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H - overlap + rib_H/2])
      rotate([0, 0, -pad_angle_deg]) pad_ribs();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H - overlap + rib_H/2])
      rotate([0, 0, pad_angle_deg]) pad_ribs();
  }
}

module all_reliefs() {
  union() {
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H - overlap - relief_depth/2])
      rotate([0, 0, pad_angle_deg]) lightening_reliefs_on_pads();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H - overlap - relief_depth/2])
      rotate([0, 0, -pad_angle_deg]) lightening_reliefs_on_pads();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H - overlap - relief_depth/2])
      rotate([0, 0, -pad_angle_deg]) lightening_reliefs_on_pads();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H - overlap - relief_depth/2])
      rotate([0, 0, pad_angle_deg]) lightening_reliefs_on_pads();
  }
}

module all_chamfers_top() {
  union() {
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap - hole_pitch/2, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H - overlap - chamfer_depth/2])
      chamfer_hole_entries();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap + hole_pitch/2, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H - overlap - chamfer_depth/2])
      chamfer_hole_entries();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap - hole_pitch/2, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H - overlap - chamfer_depth/2])
      chamfer_hole_entries();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap + hole_pitch/2, W/2 - pad_inset_y - pad_W/2 + overlap, T/2 + pad_H - overlap - chamfer_depth/2])
      chamfer_hole_entries();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap - hole_pitch/2, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H - overlap - chamfer_depth/2])
      chamfer_hole_entries();
    translate([-L/2 + pad_inset_x + pad_L/2 - overlap + hole_pitch/2, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H - overlap - chamfer_depth/2])
      chamfer_hole_entries();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap - hole_pitch/2, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H - overlap - chamfer_depth/2])
      chamfer_hole_entries();
    translate([L/2 - pad_inset_x - pad_L/2 + overlap + hole_pitch/2, -W/2 + pad_inset_y + pad_W/2 - overlap, T/2 + pad_H - overlap - chamfer_depth/2])
      chamfer_hole_entries();
  }
}

module final_difference_cuts() {
  difference() {
    frame_pads_ribs();
    all_pad_holes();
    all_reliefs();
    all_chamfers_top();
  }
}

module final_model() {
  union() {
    final_difference_cuts();
    surface_text_or_markings();
  }
}

// Render the final model
final_model();
}
