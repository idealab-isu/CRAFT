// Parameters
bbox_x = 0.08; //[0.04:0.16:0.001]
bbox_y = 0.06; //[0.03:0.12:0.001]
thickness_z = 0.04; //[0.02:0.08:0.001]
hole_hex_flat_to_flat = 0.018; //[0.009:0.036:0.001]
hole_center_x = 0.018; //[0.008:0.04:0.001]
hole_center_y = 0.03; //[0.015:0.045:0.001]
neck_min_width_y = 0.028; //[0.014:0.056:0.001]
small_lobe_len_x = 0.028; //[0.014:0.056:0.001]
large_lobe_len_x = 0.052; //[0.026:0.104:0.001]
large_lobe_max_width_y = 0.06; //[0.03:0.12:0.001]
outline_margin_x = 0.002; //[0.001:0.01:0.001]
outline_margin_y = 0.002; //[0.001:0.01:0.001]
edge_chamfer_z = 0.004; //[0.001:0.01:0.001]
edge_chamfer_overlap = 0.001; //[0.0005:0.002:0.0005]
corner_fillet_r_approx = 0.003; //[0.001:0.008:0.001]
engrave_depth = 0.002; //[0.001:0.006:0.001]
engrave_radius = 0.004; //[0.002:0.01:0.001]

// Base Shapes
module two_lobe_profile_with_neck_transition() {
  linear_extrude(height=thickness_z, center=true) {
    polygon(points=[
      [-bbox_x/2 + outline_margin_x, 0],
      [-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.25, neck_min_width_y*0.50],
      [-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.75, neck_min_width_y*0.50],
      [-bbox_x/2 + outline_margin_x + small_lobe_len_x, neck_min_width_y*0.35],
      [-bbox_x/2 + outline_margin_x + small_lobe_len_x + (large_lobe_len_x - small_lobe_len_x)*0.25, large_lobe_max_width_y/2 - outline_margin_y],
      [bbox_x/2 - outline_margin_x, large_lobe_max_width_y*0.35],
      [bbox_x/2 - outline_margin_x, -large_lobe_max_width_y*0.35],
      [-bbox_x/2 + outline_margin_x + small_lobe_len_x + (large_lobe_len_x - small_lobe_len_x)*0.25, -large_lobe_max_width_y/2 + outline_margin_y],
      [-bbox_x/2 + outline_margin_x + small_lobe_len_x, -neck_min_width_y*0.35],
      [-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.75, -neck_min_width_y*0.50],
      [-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.25, -neck_min_width_y*0.50]
    ]);
  }
}

module hex_through_hole() {
  translate([-bbox_x/2 + hole_center_x, -bbox_y/2 + hole_center_y, 0])
  linear_extrude(height=thickness_z + 2*edge_chamfer_overlap, center=true) {
    polygon(points=[
      [hole_hex_flat_to_flat/2, 0],
      [hole_hex_flat_to_flat/4, hole_hex_flat_to_flat*0.4330127019],
      [-hole_hex_flat_to_flat/4, hole_hex_flat_to_flat*0.4330127019],
      [-hole_hex_flat_to_flat/2, 0],
      [-hole_hex_flat_to_flat/4, -hole_hex_flat_to_flat*0.4330127019],
      [hole_hex_flat_to_flat/4, -hole_hex_flat_to_flat*0.4330127019]
    ]);
  }
}

module small_edge_chamfer_in_Z_top_cut() {
  translate([0, 0, thickness_z/2 - edge_chamfer_z/2])
  linear_extrude(height=thickness_z, center=true) {
    polygon(points=[
      [(-bbox_x/2 + outline_margin_x) * (1 - edge_chamfer_z/thickness_z), 0],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.25) * (1 - edge_chamfer_z/thickness_z), (neck_min_width_y*0.50) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.75) * (1 - edge_chamfer_z/thickness_z), (neck_min_width_y*0.50) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x) * (1 - edge_chamfer_z/thickness_z), (neck_min_width_y*0.35) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x + (large_lobe_len_x - small_lobe_len_x)*0.25) * (1 - edge_chamfer_z/thickness_z), (large_lobe_max_width_y/2 - outline_margin_y) * (1 - edge_chamfer_z/thickness_z)],
      [(bbox_x/2 - outline_margin_x) * (1 - edge_chamfer_z/thickness_z), (large_lobe_max_width_y*0.35) * (1 - edge_chamfer_z/thickness_z)],
      [(bbox_x/2 - outline_margin_x) * (1 - edge_chamfer_z/thickness_z), (-large_lobe_max_width_y*0.35) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x + (large_lobe_len_x - small_lobe_len_x)*0.25) * (1 - edge_chamfer_z/thickness_z), (-large_lobe_max_width_y/2 + outline_margin_y) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x) * (1 - edge_chamfer_z/thickness_z), (-neck_min_width_y*0.35) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.75) * (1 - edge_chamfer_z/thickness_z), (-neck_min_width_y*0.50) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.25) * (1 - edge_chamfer_z/thickness_z), (-neck_min_width_y*0.50) * (1 - edge_chamfer_z/thickness_z)]
    ]);
  }
}

module small_edge_chamfer_in_Z_bottom_cut() {
  translate([0, 0, -thickness_z/2 + edge_chamfer_z/2])
  linear_extrude(height=thickness_z, center=true) {
    polygon(points=[
      [(-bbox_x/2 + outline_margin_x) * (1 - edge_chamfer_z/thickness_z), 0],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.25) * (1 - edge_chamfer_z/thickness_z), (neck_min_width_y*0.50) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.75) * (1 - edge_chamfer_z/thickness_z), (neck_min_width_y*0.50) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x) * (1 - edge_chamfer_z/thickness_z), (neck_min_width_y*0.35) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x + (large_lobe_len_x - small_lobe_len_x)*0.25) * (1 - edge_chamfer_z/thickness_z), (large_lobe_max_width_y/2 - outline_margin_y) * (1 - edge_chamfer_z/thickness_z)],
      [(bbox_x/2 - outline_margin_x) * (1 - edge_chamfer_z/thickness_z), (large_lobe_max_width_y*0.35) * (1 - edge_chamfer_z/thickness_z)],
      [(bbox_x/2 - outline_margin_x) * (1 - edge_chamfer_z/thickness_z), (-large_lobe_max_width_y*0.35) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x + (large_lobe_len_x - small_lobe_len_x)*0.25) * (1 - edge_chamfer_z/thickness_z), (-large_lobe_max_width_y/2 + outline_margin_y) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x) * (1 - edge_chamfer_z/thickness_z), (-neck_min_width_y*0.35) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.75) * (1 - edge_chamfer_z/thickness_z), (-neck_min_width_y*0.50) * (1 - edge_chamfer_z/thickness_z)],
      [(-bbox_x/2 + outline_margin_x + small_lobe_len_x*0.25) * (1 - edge_chamfer_z/thickness_z), (-neck_min_width_y*0.50) * (1 - edge_chamfer_z/thickness_z)]
    ]);
  }
}

module corner_fillet_approximation_sphere() {
  translate([0, 0, 0])
  sphere(r=corner_fillet_r_approx, center=true);
}

module engraving_or_marking() {
  translate([bbox_x/2 - outline_margin_x - engrave_radius, 0, thickness_z/2 - engrave_depth/2])
  cylinder(r=engrave_radius, h=engrave_depth + 2*edge_chamfer_overlap, center=true);
}

// Operations
module angled_perimeter_segments() {
  minkowski() {
    two_lobe_profile_with_neck_transition();
    corner_fillet_approximation_sphere();
  }
}

module plate_body_irregular_outline() {
  difference() {
    angled_perimeter_segments();
    hex_through_hole();
  }
}

module plate_with_small_edge_chamfer_in_Z() {
  difference() {
    plate_body_irregular_outline();
    small_edge_chamfer_in_Z_top_cut();
    small_edge_chamfer_in_Z_bottom_cut();
  }
}

module final_bracket_no_text_marking() {
  difference() {
    plate_with_small_edge_chamfer_in_Z();
    engraving_or_marking();
  }
}

// Final Output
final_bracket_no_text_marking();