// Parameters
L = 0.12; //[0.06:0.24:0.001]
W = 0.05; //[0.025:0.1:0.001]
T = 0.02; //[0.01:0.04:0.001]
corner_r = 0.006; //[0.003:0.012:0.001]
edge_margin_x = 0.008; //[0.004:0.016:0.001]
edge_margin_y = 0.006; //[0.003:0.012:0.001]
slot_len = 0.02; //[0.01:0.04:0.001]
slot_w = 0.006; //[0.003:0.012:0.001]
slot_hex_flat = 0.006; //[0.003:0.012:0.001]
slot_row_pitch_y = 0.012; //[0.006:0.024:0.001]
slot_col_pitch_x = 0.024; //[0.012:0.048:0.001]
diamond_w = 0.01; //[0.005:0.02:0.001]
diamond_h = 0.01; //[0.005:0.02:0.001]
diamond_offset_x = 0.0; //[0.0:0.02:0.001]
diamond_offset_y = 0.0; //[0.0:0.02:0.001]
tri_side = 0.01; //[0.005:0.02:0.001]
tri_offset_x = 0.038; //[0.019:0.076:0.001]
tri_offset_y = 0.016; //[0.008:0.032:0.001]
step_len = 0.09; //[0.045:0.18:0.001]
step_w = 0.01; //[0.005:0.02:0.001]
step_h = 0.006; //[0.003:0.012:0.001]
step_edge_offset_y = 0.0; //[-0.01:0.01:0.001]
end_block_len = 0.01; //[0.005:0.02:0.001]
end_block_w = 0.012; //[0.006:0.024:0.001]
end_block_h = 0.006; //[0.003:0.012:0.001]
end_block_chamfer = 0.003; //[0.0015:0.006:0.0005]
micro_round_r = 0.001; //[0.0005:0.002:0.0005]
overlap = 0.001; //[0.0005:0.002:0.0005]
cut_extra_z = 0.01; //[0.005:0.02:0.001]
rib_w = 0.002; //[0.001:0.004:0.0005]
rib_h = 0.002; //[0.001:0.004:0.0005]
notch_w = 0.004; //[0.002:0.008:0.001]
notch_d = 0.002; //[0.001:0.004:0.0005]

// Base Shapes
module rr_corner_cyl_1() {
  translate([L/2 - corner_r, W/2 - corner_r, 0])
    cylinder(r=corner_r, h=T, center=true);
}

module rr_corner_cyl_2() {
  translate([-L/2 + corner_r, W/2 - corner_r, 0])
    cylinder(r=corner_r, h=T, center=true);
}

module rr_corner_cyl_3() {
  translate([-L/2 + corner_r, -W/2 + corner_r, 0])
    cylinder(r=corner_r, h=T, center=true);
}

module rr_corner_cyl_4() {
  translate([L/2 - corner_r, -W/2 + corner_r, 0])
    cylinder(r=corner_r, h=T, center=true);
}

module step_base_raw() {
  translate([0, -W/2 + step_w/2 + step_edge_offset_y - overlap, T/2 + step_h/2 - overlap])
    cube([step_len, step_w, step_h], center=true);
}

module end_block_left_big() {
  translate([-L/2 + end_block_len/2 - overlap, 0, T/2 + end_block_h/2 - overlap])
    cube([end_block_len, end_block_w, end_block_h], center=true);
}

module end_block_left_small() {
  translate([-L/2 + end_block_len/2 - overlap, 0, T/2 + end_block_h/2 - overlap])
    cube([end_block_len - 2*end_block_chamfer, end_block_w - 2*end_block_chamfer, end_block_h], center=true);
}

module end_block_right_big() {
  translate([L/2 - end_block_len/2 + overlap, 0, T/2 + end_block_h/2 - overlap])
    cube([end_block_len, end_block_w, end_block_h], center=true);
}

module end_block_right_small() {
  translate([L/2 - end_block_len/2 + overlap, 0, T/2 + end_block_h/2 - overlap])
    cube([end_block_len - 2*end_block_chamfer, end_block_w - 2*end_block_chamfer, end_block_h], center=true);
}

module rib_between_rows_1() {
  translate([0, 0, T/2 + rib_h/2 - overlap])
    cube([L - 2*edge_margin_x, rib_w, rib_h], center=true);
}

module rib_between_cols_1() {
  translate([-slot_col_pitch_x/2, 0, T/2 + rib_h/2 - overlap])
    cube([rib_w, W - 2*edge_margin_y, rib_h], center=true);
}

module rib_between_cols_2() {
  translate([slot_col_pitch_x/2, 0, T/2 + rib_h/2 - overlap])
    cube([rib_w, W - 2*edge_margin_y, rib_h], center=true);
}

module notch_cut_left() {
  translate([-L/2 + notch_w/2, W/2 - notch_d/2, 0])
    cube([notch_w, notch_d, T + cut_extra_z], center=true);
}

module notch_cut_right() {
  translate([L/2 - notch_w/2, W/2 - notch_d/2, 0])
    cube([notch_w, notch_d, T + cut_extra_z], center=true);
}

module slot_cut_r1c1() {
  translate([-slot_col_pitch_x, slot_row_pitch_y/2, 0])
    cube([slot_len, slot_w, T + cut_extra_z], center=true);
}

module slot_cut_r1c2() {
  translate([0, slot_row_pitch_y/2, 0])
    cube([slot_len, slot_w, T + cut_extra_z], center=true);
}

module slot_cut_r1c3() {
  translate([slot_col_pitch_x, slot_row_pitch_y/2, 0])
    cube([slot_len, slot_w, T + cut_extra_z], center=true);
}

module slot_cut_r2c1() {
  translate([-slot_col_pitch_x, -slot_row_pitch_y/2, 0])
    cube([slot_len, slot_w, T + cut_extra_z], center=true);
}

module slot_cut_r2c2() {
  translate([0, -slot_row_pitch_y/2, 0])
    cube([slot_len, slot_w, T + cut_extra_z], center=true);
}

module slot_cut_r2c3() {
  translate([slot_col_pitch_x, -slot_row_pitch_y/2, 0])
    cube([slot_len, slot_w, T + cut_extra_z], center=true);
}

module hex_like_cut_center() {
  translate([0, 0, 0])
    cube([slot_len*0.6, slot_hex_flat, T + cut_extra_z], center=true);
}

module diamond_cut_1_raw() {
  translate([diamond_offset_x - slot_col_pitch_x/2, diamond_offset_y, 0])
    cube([diamond_w, diamond_h, T + cut_extra_z], center=true);
}

module diamond_cut_2_raw() {
  translate([diamond_offset_x + slot_col_pitch_x/2, diamond_offset_y, 0])
    cube([diamond_w, diamond_h, T + cut_extra_z], center=true);
}

module tri_cut_1_raw() {
  translate([tri_offset_x, tri_offset_y, 0])
    cube([tri_side, tri_side, T + cut_extra_z], center=true);
}

module tri_cut_2_raw() {
  translate([-tri_offset_x, tri_offset_y, 0])
    cube([tri_side, tri_side, T + cut_extra_z], center=true);
}

module tri_cut_3_raw() {
  translate([tri_offset_x, -tri_offset_y, 0])
    cube([tri_side, tri_side, T + cut_extra_z], center=true);
}

module tri_cut_4_raw() {
  translate([-tri_offset_x, -tri_offset_y, 0])
    cube([tri_side, tri_side, T + cut_extra_z], center=true);
}

module micro_round_sphere() {
  translate([0, 0, 0])
    sphere(r=micro_round_r, center=true);
}

// Operations
module main_plate_rounded_rectangle() {
  hull() {
    rr_corner_cyl_1();
    rr_corner_cyl_2();
    rr_corner_cyl_3();
    rr_corner_cyl_4();
  }
}

module chamfered_corner_end_block_left() {
  hull() {
    end_block_left_big();
    end_block_left_small();
  }
}

module chamfered_corner_end_block_right() {
  hull() {
    end_block_right_big();
    end_block_right_small();
  }
}

module chamfered_corner_end_blocks() {
  union() {
    chamfered_corner_end_block_left();
    chamfered_corner_end_block_right();
  }
}

module stepped_base_along_long_edge() {
  step_base_raw();
}

module decorative_spacing_ribs_between_cutouts() {
  union() {
    rib_between_rows_1();
    rib_between_cols_1();
    rib_between_cols_2();
  }
}

module panel_with_addons_union() {
  union() {
    main_plate_rounded_rectangle();
    stepped_base_along_long_edge();
    chamfered_corner_end_blocks();
    decorative_spacing_ribs_between_cutouts();
  }
}

module edge_fillet_micro_rounding() {
  minkowski() {
    panel_with_addons_union();
    micro_round_sphere();
  }
}

module through_cutout_pattern_slots_hex() {
  union() {
    slot_cut_r1c1();
    slot_cut_r1c2();
    slot_cut_r1c3();
    slot_cut_r2c1();
    slot_cut_r2c2();
    slot_cut_r2c3();
    hex_like_cut_center();
  }
}

module diamond_cut_1_rot() {
  rotate([0, 0, 45]) diamond_cut_1_raw();
}

module diamond_cut_2_rot() {
  rotate([0, 0, 45]) diamond_cut_2_raw();
}

module through_cutout_pattern_diamonds() {
  union() {
    diamond_cut_1_rot();
    diamond_cut_2_rot();
  }
}

module tri_cut_1_rot() {
  rotate([0, 0, 45]) tri_cut_1_raw();
}

module tri_cut_2_rot() {
  rotate([0, 0, 45]) tri_cut_2_raw();
}

module tri_cut_3_rot() {
  rotate([0, 0, 45]) tri_cut_3_raw();
}

module tri_cut_4_rot() {
  rotate([0, 0, 45]) tri_cut_4_raw();
}

module through_cutout_pattern_triangles() {
  union() {
    tri_cut_1_rot();
    tri_cut_2_rot();
    tri_cut_3_rot();
    tri_cut_4_rot();
  }
}

module tiny_alignment_notches() {
  union() {
    notch_cut_left();
    notch_cut_right();
  }
}

module all_through_cutouts_union() {
  union() {
    through_cutout_pattern_slots_hex();
    through_cutout_pattern_diamonds();
    through_cutout_pattern_triangles();
    tiny_alignment_notches();
  }
}

module final_panel_with_cutouts() {
  difference() {
    edge_fillet_micro_rounding();
    all_through_cutouts_union();
  }
}

// Final Output
final_panel_with_cutouts();