// Parameters
blade_L = 300; //[150:600:1]
blade_W = 25; //[12.5:50:0.5]
blade_T = 0.9; //[0.45:1.8:0.05]
tooth_pitch = 2.5; //[1.25:5:0.05]
tooth_H = 1.2; //[0.6:2.4:0.05]
tooth_tip_angle = 60; //[30:90:1]
tooth_root_R = 0.2; //[0.1:0.6:0.05]
mount_hole_d = 6; //[3:12:0.1]
mount_hole_edge_offset = 12; //[6:24:0.5]
end_round_R = 3; //[1.5:8:0.5]
bimetal_band_W = 3; //[1.5:8:0.5]
overlap = 0.8; //[0.2:2:0.1]
tooth_skew_deg = 8; //[0:20:1]
tooth_count = 80; //[20:200:1]
chamfer_C = 1; //[0.5:3:0.1]

// Base Shapes
module blade_body_sheet() {
  translate([0, 0, 0])
    cube([blade_L, blade_W, blade_T], center=true);
}

module end_profile_left_cap() {
  translate([-blade_L/2 + blade_W/2, 0, 0])
    rotate([90, 0, 0])
      cylinder(r=blade_W/2, h=blade_T, center=true);
}

module end_profile_right_cap() {
  translate([blade_L/2 - blade_W/2, 0, 0])
    rotate([90, 0, 0])
      cylinder(r=blade_W/2, h=blade_T, center=true);
}

module mounting_hole_or_slot() {
  translate([-blade_L/2 + mount_hole_edge_offset, 0, 0])
    cylinder(r=mount_hole_d/2, h=blade_T + 2*overlap, center=true);
}

module bi_metal_edge_band() {
  translate([0, blade_W/2 - bimetal_band_W/2, 0])
    cube([blade_L, bimetal_band_W, blade_T], center=true);
}

module tooth_base() {
  translate([0, blade_W/2 - overlap, 0])
    linear_extrude(height=blade_T, center=true)
      polygon(points=[[-tooth_pitch/2, 0], [tooth_pitch/2, 0], [0, tooth_H]]);
}

module tooth_row() {
  translate([0, blade_W/2 + tooth_H/2 - overlap, 0])
    cube([blade_L, tooth_pitch, blade_T], center=true);
}

module tooth_set_alternation() {
  translate([0, blade_W/2 + tooth_H/2 - overlap, 0])
    rotate([0, 0, tooth_skew_deg])
      cube([blade_L, tooth_pitch, blade_T], center=true);
}

module corner_chamfer_cut_tl() {
  translate([-blade_L/2 + chamfer_C/2, blade_W/2 - chamfer_C/2, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, chamfer_C, blade_T + 2*overlap], center=true);
}

module corner_chamfer_cut_tr() {
  translate([blade_L/2 - chamfer_C/2, blade_W/2 - chamfer_C/2, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, chamfer_C, blade_T + 2*overlap], center=true);
}

module corner_chamfer_cut_bl() {
  translate([-blade_L/2 + chamfer_C/2, -blade_W/2 + chamfer_C/2, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, chamfer_C, blade_T + 2*overlap], center=true);
}

module corner_chamfer_cut_br() {
  translate([blade_L/2 - chamfer_C/2, -blade_W/2 + chamfer_C/2, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, chamfer_C, blade_T + 2*overlap], center=true);
}

module engraved_text_markings() {
  translate([0, 0, blade_T/2 - blade_T/20])
    cube([blade_L/4, blade_W/4, blade_T/10], center=true);
}

module surface_texture_finish() {
  translate([0, 0, blade_T/2 - blade_T/100])
    cube([blade_L, blade_W, blade_T/50], center=true);
}

// Operations
module end_profile_union() {
  union() {
    blade_body_sheet();
    end_profile_left_cap();
    end_profile_right_cap();
  }
}

module blade_with_hole() {
  difference() {
    end_profile_union();
    mounting_hole_or_slot();
  }
}

module blade_with_chamfers() {
  difference() {
    blade_with_hole();
    corner_chamfer_cut_tl();
    corner_chamfer_cut_tr();
    corner_chamfer_cut_bl();
    corner_chamfer_cut_br();
  }
}

module blade_with_bimetal_band() {
  union() {
    blade_with_chamfers();
    bi_metal_edge_band();
  }
}

module blade_with_teeth() {
  union() {
    blade_with_bimetal_band();
    tooth_row();
    tooth_set_alternation();
    tooth_base();
  }
}

module final_model() {
  difference() {
    blade_with_teeth();
    engraved_text_markings();
    surface_texture_finish();
  }
}

// Final Output
final_model();