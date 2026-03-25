// Parameters
plate_L = 65; //[32.5:130:0.5]
plate_W = 20; //[10:40:0.5]
plate_T = 4; //[2:8:0.25]
outer_corner_R = 2; //[1:4:0.25]
window_W = 22; //[11:44:0.5]
window_H = 12; //[6:24:0.5]
window_corner_R = 1; //[0.5:2:0.25]
window_gap = 5; //[2.5:10:0.5]
window_center_Y = 0; //[-5:5:0.5]
center_hole_d = 2; //[1:4:0.25]
center_hole_pitch_Y = 6; //[3:12:0.5]
mount_hole_d = 3; //[1.5:6:0.25]
mount_hole_offset_X = 5; //[2.5:10:0.5]
mount_hole_center_Y = 0; //[-5:5:0.5]
through_cut_h = 6; //[4:12:0.5]
cut_z_overlap = 1; //[0.5:2:0.25]
outer_round_tool_r = 2; //[1:4:0.25]
window_round_tool_r = 1; //[0.5:2:0.25]
edge_chamfer_size = 0; //[0:1.5:0.25]
engrave_depth = 0; //[0:1:0.25]
engrave_L = 20; //[10:40:0.5]
engrave_W = 6; //[3:12:0.5]
engrave_center_Y = 0; //[-5:5:0.5]
eps = 0.01; //[0.001:0.1:0.001]

// Base Shapes
module outer_plate() {
  cube([plate_L, plate_W, plate_T], center=true);
}

module outer_corner_rounding(pos) {
  translate(pos)
    cylinder(r=outer_round_tool_r, h=plate_T + 2*cut_z_overlap, center=true);
}

module outer_corner_square(pos) {
  translate(pos)
    cube([outer_corner_R*2, outer_corner_R*2, plate_T + 2*cut_z_overlap], center=true);
}

module window_cutout(pos) {
  translate(pos)
    cube([window_W, window_H, plate_T + 2*cut_z_overlap], center=true);
}

module window_corner_rounding(pos) {
  translate(pos)
    cylinder(r=window_round_tool_r, h=plate_T + 2*cut_z_overlap, center=true);
}

module center_hole(pos) {
  translate(pos)
    cylinder(r=center_hole_d/2, h=plate_T + 2*cut_z_overlap, center=true);
}

module mount_hole(pos) {
  translate(pos)
    cylinder(r=mount_hole_d/2, h=plate_T + 2*cut_z_overlap, center=true);
}

module edge_chamfer() {
  translate([0, 0, plate_T/2 - edge_chamfer_size/2])
    cube([plate_L + eps, plate_W + eps, edge_chamfer_size], center=true);
}

module engraving_or_label_recess() {
  translate([0, engrave_center_Y, plate_T/2 - engrave_depth/2])
    cube([engrave_L, engrave_W, engrave_depth], center=true);
}

// Operations
module outer_plate_rounded() {
  difference() {
    outer_plate();
    outer_corner_rounding([plate_L/2 - outer_corner_R, plate_W/2 - outer_corner_R, 0]);
    outer_corner_rounding([-(plate_L/2 - outer_corner_R), plate_W/2 - outer_corner_R, 0]);
    outer_corner_rounding([plate_L/2 - outer_corner_R, -(plate_W/2 - outer_corner_R), 0]);
    outer_corner_rounding([-(plate_L/2 - outer_corner_R), -(plate_W/2 - outer_corner_R), 0]);
  }
}

module window_corner_rounding_all() {
  union() {
    window_corner_rounding([-(window_gap/2 + window_W/2) + (window_W/2 - window_corner_R), window_center_Y + (window_H/2 - window_corner_R), 0]);
    window_corner_rounding([-(window_gap/2 + window_W/2) - (window_W/2 - window_corner_R), window_center_Y + (window_H/2 - window_corner_R), 0]);
    window_corner_rounding([-(window_gap/2 + window_W/2) + (window_W/2 - window_corner_R), window_center_Y - (window_H/2 - window_corner_R), 0]);
    window_corner_rounding([-(window_gap/2 + window_W/2) - (window_W/2 - window_corner_R), window_center_Y - (window_H/2 - window_corner_R), 0]);
    window_corner_rounding([window_gap/2 + window_W/2 - (window_W/2 - window_corner_R), window_center_Y + (window_H/2 - window_corner_R), 0]);
    window_corner_rounding([window_gap/2 + window_W/2 + (window_W/2 - window_corner_R), window_center_Y + (window_H/2 - window_corner_R), 0]);
    window_corner_rounding([window_gap/2 + window_W/2 - (window_W/2 - window_corner_R), window_center_Y - (window_H/2 - window_corner_R), 0]);
    window_corner_rounding([window_gap/2 + window_W/2 + (window_W/2 - window_corner_R), window_center_Y - (window_H/2 - window_corner_R), 0]);
  }
}

module all_cutouts() {
  union() {
    window_cutout([-(window_gap/2 + window_W/2), window_center_Y, 0]);
    window_cutout([window_gap/2 + window_W/2, window_center_Y, 0]);
    window_corner_rounding_all();
    center_hole([0, window_center_Y + center_hole_pitch_Y/2, 0]);
    center_hole([0, window_center_Y - center_hole_pitch_Y/2, 0]);
    mount_hole([-(plate_L/2 - mount_hole_offset_X), mount_hole_center_Y, 0]);
    mount_hole([plate_L/2 - mount_hole_offset_X, mount_hole_center_Y, 0]);
    engraving_or_label_recess();
    edge_chamfer();
  }
}

// Final Output
difference() {
  outer_plate_rounded();
  all_cutouts();
}