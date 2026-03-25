// Parameters
bbox_X = 52.33; //[26.165:104.66:0.01]
bbox_Y = 50; //[25:100:0.01]
bbox_Z = 38.77; //[19.385:77.54:0.01]
plate_len_X = 34; //[17:68:0.01]
plate_max_W_Y = 50; //[25:100:0.01]
plate_min_W_Y = 26; //[13:52:0.01]
plate_H_Z = 12; //[6:24:0.01]
stem_len_X = 18.33; //[9.165:36.66:0.01]
stem_W_Y = 18; //[9:36:0.01]
stem_H_Z = 38.77; //[19.385:77.54:0.01]
neck_len_X = 4; //[2:8:0.01]
hole_d = 8; //[4:16:0.01]
hole_center_from_stem_end_X = 6; //[3:12:0.01]
hole_center_Z = 19.385; //[9.6925:38.77:0.01]
ridge_height_Z = 2; //[1:4:0.01]
ridge_base_W_Y = 10; //[5:20:0.01]
step_depth_Y = 4; //[2:8:0.01]
step_height_Z = 6; //[3:12:0.01]
wall_t = 2.2; //[1.1:4.4:0.01]
relief_margin = 2.5; //[1.25:5:0.01]
overlap = 1; //[0.5:2:0.01]
chamfer_r = 1.2; //[0.6:2.4:0.01]
lip_thk_X = 2; //[1:4:0.01]
lip_H_Z = 2.5; //[1.25:5:0.01]
lip_inset_Y = 1.5; //[0.75:3:0.01]

// Base Shapes
module v_flared_plate_main_body() {
  linear_extrude(height=plate_H_Z)
    polygon(points=[
      [-plate_len_X/2, -plate_max_W_Y/2],
      [-plate_len_X/2, plate_max_W_Y/2],
      [plate_len_X/2, plate_min_W_Y/2],
      [plate_len_X/2, -plate_min_W_Y/2]
    ]);
}

module rectangular_stem() {
  translate([plate_len_X/2 + neck_len_X + stem_len_X/2 - overlap, 0, stem_H_Z/2 - plate_H_Z/2])
    cube([stem_len_X, stem_W_Y, stem_H_Z], center=true);
}

module transition_neck_between_v_plate_and_stem() {
  translate([plate_len_X/2 + neck_len_X/2 - overlap, 0, 0])
    linear_extrude(height=plate_H_Z)
      polygon(points=[
        [-neck_len_X/2, -plate_min_W_Y/2],
        [-neck_len_X/2, plate_min_W_Y/2],
        [neck_len_X/2, stem_W_Y/2],
        [neck_len_X/2, -stem_W_Y/2]
      ]);
}

module v_plate_central_ridge() {
  translate([0, 0, plate_H_Z/2 + ridge_height_Z/2 - overlap])
    linear_extrude(height=ridge_height_Z)
      polygon(points=[
        [-plate_len_X/2, -ridge_base_W_Y/2],
        [-plate_len_X/2, ridge_base_W_Y/2],
        [plate_len_X/2, 0]
      ]);
}

module stepped_side_profiles() {
  cube([plate_len_X, step_depth_Y, step_height_Z], center=true);
}

module internal_relief_pockets_to_reduce_solidity_plate() {
  translate([0, 0, wall_t/2])
    linear_extrude(height=plate_H_Z - wall_t)
      polygon(points=[
        [-plate_len_X/2 + relief_margin, -plate_max_W_Y/2 + relief_margin],
        [-plate_len_X/2 + relief_margin, plate_max_W_Y/2 - relief_margin],
        [plate_len_X/2 - relief_margin, plate_min_W_Y/2 - relief_margin],
        [plate_len_X/2 - relief_margin, -plate_min_W_Y/2 + relief_margin]
      ]);
}

module internal_relief_pockets_to_reduce_solidity_stem() {
  translate([plate_len_X/2 + neck_len_X + stem_len_X/2 - overlap, 0, stem_H_Z/2 - plate_H_Z/2])
    cube([stem_len_X - 2*relief_margin, stem_W_Y - 2*relief_margin, stem_H_Z - 2*relief_margin], center=true);
}

module stem_through_hole() {
  translate([plate_len_X/2 + neck_len_X + stem_len_X - hole_center_from_stem_end_X, 0, hole_center_Z - plate_H_Z/2])
    rotate([90, 0, 0])
      cylinder(r=hole_d/2, h=stem_W_Y + 2*overlap, center=true);
}

module small_locating_lips_or_stops() {
  translate([-plate_len_X/2 + lip_thk_X/2 - overlap, 0, -plate_H_Z/2 + lip_H_Z/2])
    cube([lip_thk_X, plate_max_W_Y - 2*lip_inset_Y, lip_H_Z], center=true);
}

module edge_chamfers_or_fillets_sphere() {
  sphere(r=chamfer_r, center=true);
}

// Assembly
module main_union_pre_relief() {
  union() {
    v_flared_plate_main_body();
    transition_neck_between_v_plate_and_stem();
    rectangular_stem();
    v_plate_central_ridge();
    translate([0, plate_max_W_Y/2 - step_depth_Y/2 - overlap, plate_H_Z/2 - step_height_Z/2])
      stepped_side_profiles();
    translate([0, -(plate_max_W_Y/2 - step_depth_Y/2 - overlap), plate_H_Z/2 - step_height_Z/2])
      stepped_side_profiles();
    small_locating_lips_or_stops();
  }
}

module main_with_reliefs() {
  difference() {
    main_union_pre_relief();
    internal_relief_pockets_to_reduce_solidity_plate();
    internal_relief_pockets_to_reduce_solidity_stem();
  }
}

module main_with_reliefs_and_hole() {
  difference() {
    main_with_reliefs();
    stem_through_hole();
  }
}

// Final Output
difference() {
  main_with_reliefs_and_hole();
  edge_chamfers_or_fillets_sphere();
}