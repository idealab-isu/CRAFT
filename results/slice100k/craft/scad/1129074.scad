// Parameters
L = 24.5; //[12.25:49:0.1]
W = 7.75; //[3.875:15.5:0.05]
H = 4.5; //[2.25:9:0.05]
slot_L = 18.5; //[9.25:22.5:0.1]
slot_W = 3.6; //[1.8:6.5:0.05]
slot_end_r = 1.8; //[0.9:3.25:0.05]
tip_L = 4.0; //[2.0:8.0:0.1]
mid_W = 7.75; //[3.875:15.5:0.05]
end_W = 2.6; //[1.3:5.2:0.05]
notch_L = 4.2; //[2.1:8.4:0.1]
notch_D = 0.7; //[0.35:1.4:0.05]
notch_H = 1.6; //[0.8:3.2:0.05]
facet_flat_W = 6.6; //[3.3:7.75:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
bevel_drop = 0.9; //[0.4:1.6:0.05]
edge_chamfer = 0.35; //[0.15:0.8:0.05]
fillet_r = 0.35; //[0.15:0.9:0.05]

// Base Shapes
module outer_body() {
  linear_extrude(height=H, center=true)
    polygon(points=[
      [-L/2, 0],
      [-L/2 + tip_L, mid_W/2],
      [L/2 - tip_L, mid_W/2],
      [L/2, 0],
      [L/2 - tip_L, -mid_W/2],
      [-L/2 + tip_L, -mid_W/2]
    ]);
}

module faceted_outer_profile() {
  linear_extrude(height=H, center=true)
    polygon(points=[
      [-L/2, 0],
      [-L/2 + tip_L, facet_flat_W/2],
      [L/2 - tip_L, facet_flat_W/2],
      [L/2, 0],
      [L/2 - tip_L, -facet_flat_W/2],
      [-L/2 + tip_L, -facet_flat_W/2]
    ]);
}

module facet_top_wedge() {
  linear_extrude(height=H, center=true)
    polygon(points=[
      [-L/2 - overlap, -W/2 - overlap],
      [L/2 + overlap, -W/2 - overlap],
      [L/2 + overlap, W/2 + overlap],
      [-L/2 - overlap, W/2 + overlap]
    ]);
}

module facet_bottom_wedge() {
  linear_extrude(height=H, center=true)
    polygon(points=[
      [-L/2 - overlap, -W/2 - overlap],
      [L/2 + overlap, -W/2 - overlap],
      [L/2 + overlap, W/2 + overlap],
      [-L/2 - overlap, W/2 + overlap]
    ]);
}

module end_tapered_tips() {
  linear_extrude(height=H, center=true)
    polygon(points=[
      [-L/2, 0],
      [-L/2 + tip_L, mid_W/2],
      [-L/2 + tip_L, -mid_W/2]
    ]);
}

module end_tapered_tips_mirror() {
  linear_extrude(height=H, center=true)
    polygon(points=[
      [L/2, 0],
      [L/2 - tip_L, mid_W/2],
      [L/2 - tip_L, -mid_W/2]
    ]);
}

module central_through_slot_rect() {
  cube([slot_L - 2*slot_end_r, slot_W, H + 2*overlap], center=true);
}

module central_through_slot_end() {
  rotate([90, 0, 0])
    cylinder(r=slot_end_r, h=H + 2*overlap, center=true);
}

module side_relief_notch() {
  cube([notch_L, notch_D + overlap, notch_H], center=true);
}

module edge_chamfer_long() {
  cube([L + 2*overlap, edge_chamfer, H + 2*overlap], center=true);
}

module surface_bevel_accent() {
  cube([L - 2*tip_L, W + 2*overlap, edge_chamfer + overlap], center=true);
}

module small_fillet_rounding_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module facet_top_wedge_rot() {
  rotate([-45, 0, 0]) facet_top_wedge();
}

module facet_top_wedge_pos() {
  translate([0, 0, H/2 - bevel_drop/2]) facet_top_wedge_rot();
}

module facet_bottom_wedge_rot() {
  rotate([45, 0, 0]) facet_bottom_wedge();
}

module facet_bottom_wedge_pos() {
  translate([0, 0, -H/2 + bevel_drop/2]) facet_bottom_wedge_rot();
}

module faceted_cutters_union() {
  union() {
    facet_top_wedge_pos();
    facet_bottom_wedge_pos();
  }
}

module outer_body_faceted() {
  intersection() {
    outer_body();
    faceted_outer_profile();
  }
}

module outer_body_with_facets() {
  intersection() {
    outer_body_faceted();
    outer_body();
  }
}

module slot_end1_pos() {
  translate([-(slot_L/2 - slot_end_r), 0, 0]) central_through_slot_end();
}

module slot_end2_pos() {
  translate([(slot_L/2 - slot_end_r), 0, 0]) central_through_slot_end();
}

module central_through_slot() {
  union() {
    central_through_slot_rect();
    slot_end1_pos();
    slot_end2_pos();
  }
}

module notch_right_pos() {
  translate([0, W/2 - (notch_D/2) + overlap/2, 0]) side_relief_notch();
}

module notch_left_pos() {
  translate([0, -W/2 + (notch_D/2) - overlap/2, 0]) side_relief_notch();
}

module side_relief_notches() {
  union() {
    notch_right_pos();
    notch_left_pos();
  }
}

module edge_chamfer_pos_y() {
  translate([0, W/2 - edge_chamfer/2 + overlap/2, 0]) edge_chamfer_long();
}

module edge_chamfer_neg_y() {
  translate([0, -W/2 + edge_chamfer/2 - overlap/2, 0]) edge_chamfer_long();
}

module edge_chamfers() {
  union() {
    edge_chamfer_pos_y();
    edge_chamfer_neg_y();
  }
}

module surface_bevel_top_pos() {
  translate([0, 0, H/2 - (edge_chamfer/2) + overlap/2]) surface_bevel_accent();
}

module surface_bevel_bottom_pos() {
  translate([0, 0, -H/2 + (edge_chamfer/2) - overlap/2]) surface_bevel_accent();
}

module surface_bevel_accents() {
  union() {
    surface_bevel_top_pos();
    surface_bevel_bottom_pos();
  }
}

module outer_minus_slot() {
  difference() {
    outer_body_with_facets();
    central_through_slot();
  }
}

module outer_minus_slot_minus_notches() {
  difference() {
    outer_minus_slot();
    side_relief_notches();
  }
}

module outer_minus_edge_chamfers() {
  difference() {
    outer_minus_slot_minus_notches();
    edge_chamfers();
  }
}

module outer_minus_bevel_accents() {
  difference() {
    outer_minus_edge_chamfers();
    surface_bevel_accents();
  }
}

// Final Output
minkowski() {
  outer_minus_bevel_accents();
  small_fillet_rounding_sphere();
}