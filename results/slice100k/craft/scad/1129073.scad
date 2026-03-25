// Dimension-calibrated (target: 7.75 x 24.50 x 4.50 mm)
scale([1.041082, 1.137074, 0.666053])
{
// Parameters
L = 24.5; //[12.25:49:0.1]
W = 7.75; //[3.875:15.5:0.05]
H = 4.5; //[2.25:9:0.05]
end_tip_len = 5.5; //[2.75:11:0.1]
mid_len = 13.5; //[6.75:27:0.1]
slot_L = 18; //[9:36:0.1]
slot_W = 3.6; //[1.8:7.2:0.05]
slot_end_r = 1.8; //[0.9:3.6:0.05]
slot_clearance_to_outer_min = 1; //[0.5:2:0.05]
notch_L = 3.2; //[1.6:6.4:0.05]
notch_W = 1.2; //[0.6:2.4:0.05]
notch_depth = 0.8; //[0.4:1.6:0.05]
notch_center_offset_from_mid = 0; //[-3:3:0.1]
facet_chamfer = 0.8; //[0.4:1.6:0.05]
top_bottom_chamfer = 0.6; //[0.3:1.2:0.05]
eps_overlap = 0.8; //[0.2:2:0.1]
slot_height = 6; //[4.5:12:0.1]
notch_micro_chamfer = 0.25; //[0.1:0.6:0.05]
edge_fillet_r_small = 0.35; //[0.15:0.8:0.05]
surface_detail_depth = 0.25; //[0.1:0.6:0.05]
surface_detail_band_L = 10; //[5:20:0.1]

// Base Shapes
module outer_mid_box() {
  translate([0, 0, 0])
    cube([mid_len, W, H], center=true);
}

module outer_tip_cone_pos() {
  translate([mid_len/2 + end_tip_len/2 - eps_overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=end_tip_len, r1=W/2, r2=0, center=true);
}

module outer_tip_cone_neg() {
  translate([-(mid_len/2 + end_tip_len/2 - eps_overlap), 0, 0])
    rotate([0, -90, 0])
      cylinder(h=end_tip_len, r1=W/2, r2=0, center=true);
}

module facet_mid_box() {
  translate([0, 0, 0])
    cube([mid_len, W - 2*facet_chamfer, H - 2*top_bottom_chamfer], center=true);
}

module facet_tip_cone_pos() {
  translate([mid_len/2 + end_tip_len/2 - eps_overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=end_tip_len, r1=W/2 - facet_chamfer, r2=0, center=true);
}

module facet_tip_cone_neg() {
  translate([-(mid_len/2 + end_tip_len/2 - eps_overlap), 0, 0])
    rotate([0, -90, 0])
      cylinder(h=end_tip_len, r1=W/2 - facet_chamfer, r2=0, center=true);
}

module slot_rect() {
  translate([0, 0, 0])
    cube([slot_L - 2*slot_end_r, slot_W, slot_height], center=true);
}

module slot_end_cyl_pos() {
  translate([slot_L/2 - slot_end_r, 0, 0])
    rotate([90, 0, 0])
      cylinder(h=slot_height, r=slot_end_r, center=true);
}

module slot_end_cyl_neg() {
  translate([-(slot_L/2 - slot_end_r), 0, 0])
    rotate([90, 0, 0])
      cylinder(h=slot_height, r=slot_end_r, center=true);
}

module notch_left_cut() {
  translate([notch_center_offset_from_mid, -(W/2 - (notch_W + eps_overlap)/2) - eps_overlap/2, H/2 - notch_depth/2])
    cube([notch_L, notch_W + eps_overlap, notch_depth], center=true);
}

module notch_right_cut() {
  translate([notch_center_offset_from_mid, (W/2 - (notch_W + eps_overlap)/2) + eps_overlap/2, H/2 - notch_depth/2])
    cube([notch_L, notch_W + eps_overlap, notch_depth], center=true);
}

module notch_left_micro_wedge() {
  translate([notch_center_offset_from_mid, -(W/2 - (notch_W + eps_overlap)/2) - eps_overlap/2, H/2 - notch_depth + notch_micro_chamfer/2])
    cube([notch_L + 2*notch_micro_chamfer, notch_W + eps_overlap, notch_micro_chamfer], center=true);
}

module notch_right_micro_wedge() {
  translate([notch_center_offset_from_mid, (W/2 - (notch_W + eps_overlap)/2) + eps_overlap/2, H/2 - notch_depth + notch_micro_chamfer/2])
    cube([notch_L + 2*notch_micro_chamfer, notch_W + eps_overlap, notch_micro_chamfer], center=true);
}

module surface_detail_band_cut() {
  translate([0, 0, H/2 - surface_detail_depth/2])
    cube([surface_detail_band_L, W - 2*facet_chamfer, surface_detail_depth], center=true);
}

module edge_fillet_sphere() {
  translate([0, 0, 0])
    sphere(r=edge_fillet_r_small, center=true);
}

// Operations
module outer_spindle_body() {
  union() {
    outer_mid_box();
    outer_tip_cone_pos();
    outer_tip_cone_neg();
  }
}

module faceted_chamfered_outer_surfaces() {
  hull() {
    facet_mid_box();
    facet_tip_cone_pos();
    facet_tip_cone_neg();
  }
}

module outer_body_with_facets() {
  intersection() {
    outer_spindle_body();
    faceted_chamfered_outer_surfaces();
  }
}

module central_through_slot_obround() {
  union() {
    slot_rect();
    slot_end_cyl_pos();
    slot_end_cyl_neg();
  }
}

module body_minus_slot() {
  difference() {
    outer_body_with_facets();
    central_through_slot_obround();
  }
}

module body_minus_slot_and_notches() {
  difference() {
    body_minus_slot();
    notch_left_cut();
    notch_right_cut();
  }
}

module micro_chamfers_on_notches() {
  difference() {
    body_minus_slot_and_notches();
    notch_left_micro_wedge();
    notch_right_micro_wedge();
  }
}

module surface_detailing() {
  difference() {
    micro_chamfers_on_notches();
    surface_detail_band_cut();
  }
}

module edge_fillets_small() {
  minkowski() {
    surface_detailing();
    edge_fillet_sphere();
  }
}

// Final Output
edge_fillets_small();
}
