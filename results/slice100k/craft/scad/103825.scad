// Dimension-calibrated (target: 22.15 x 24.30 x 79.00 mm)
scale([1.029783, 0.981103, 0.275547])
{
// Parameters
bbox_X = 22.15; //[11.08:44.3:0.01]
bbox_Y = 24.3; //[12.15:48.6:0.01]
bbox_Z = 79; //[39.5:158:0.01]
wall_t = 2.2; //[1.1:4.4:0.01]
channel_X = 17.75; //[8.88:35.5:0.01]
channel_Y = 15; //[7.5:30:0.01]
back_round_r = 11.075; //[5.54:22.15:0.001]
front_opening_Y = 9.3; //[4.65:18.6:0.01]
hole_d = 4.2; //[2.1:8.4:0.01]
hole_center_Z = 60; //[30:75:0.01]
hole_center_Y = 0; //[-5:5:0.01]
hole_edge_clearance = 3; //[1.5:6:0.01]
tab_len_Y = 2; //[1:4:0.01]
tab_thk_Z = 1.8; //[0.9:3.6:0.01]
tab_height_Z = 6; //[3:12:0.01]
fillet_r_internal = 2.5; //[1.25:5:0.01]
overlap = 1; //[0.5:2:0.1]
hole_lead_in = 0.6; //[0.3:1.2:0.01]
hole_lead_scale = 1.35; //[1.1:1.8:0.01]
cosmetic_fillet_r = 0.8; //[0.4:1.6:0.01]
sym_break_depth = 0.6; //[0.3:1.2:0.01]
sym_break_w = 3; //[1.5:6:0.01]
sym_break_h = 8; //[4:16:0.01]

// Base Shapes
module u_channel_body_outer_box() {
  cube([bbox_X, bbox_Y, bbox_Z], center=true);
}

module rounded_outer_back_cyl() {
  rotate([90, 0, 0])
    cylinder(r=back_round_r, h=bbox_Z, center=true);
}

module open_front_gap_inner_box() {
  translate([0, (bbox_Y - channel_Y)/2 - overlap, 0])
    cube([channel_X, channel_Y, bbox_Z], center=true);
}

module internal_fillet_rounding_sphere() {
  sphere(r=fillet_r_internal, center=true);
}

module cosmetic_outer_fillets_sphere() {
  sphere(r=cosmetic_fillet_r, center=true);
}

module through_hole_cyl_main() {
  translate([0, hole_center_Y, hole_center_Z - bbox_Z/2])
    rotate([0, 90, 0])
      cylinder(r=hole_d/2, h=bbox_X + 2*overlap, center=true);
}

module hole_lead_in_cone_left() {
  translate([-bbox_X/2 + hole_lead_in/2, hole_center_Y, hole_center_Z - bbox_Z/2])
    rotate([0, 90, 0])
      cylinder(r1=(hole_d/2)*hole_lead_scale, r2=hole_d/2, h=hole_lead_in, center=true);
}

module hole_lead_in_cone_right() {
  translate([bbox_X/2 - hole_lead_in/2, hole_center_Y, hole_center_Z - bbox_Z/2])
    rotate([0, -90, 0])
      cylinder(r1=(hole_d/2)*hole_lead_scale, r2=hole_d/2, h=hole_lead_in, center=true);
}

module end_tab_left() {
  translate([-(channel_X/2 + wall_t/2 - overlap), bbox_Y/2 + tab_len_Y/2 - overlap, -bbox_Z/2 + tab_height_Z/2])
    cube([wall_t, tab_len_Y, tab_thk_Z], center=true);
}

module end_tab_right() {
  translate([(channel_X/2 + wall_t/2 - overlap), bbox_Y/2 + tab_len_Y/2 - overlap, -bbox_Z/2 + tab_height_Z/2])
    cube([wall_t, tab_len_Y, tab_thk_Z], center=true);
}

module symmetry_break_notch() {
  translate([bbox_X/2 - sym_break_w/2, bbox_Y/2 - sym_break_depth/2, -bbox_Z/2 + sym_break_h/2 + tab_thk_Z])
    cube([sym_break_w, sym_break_depth, sym_break_h], center=true);
}

// Operations
module u_channel_body_outer_union() {
  union() {
    u_channel_body_outer_box();
    rounded_outer_back_cyl();
  }
}

module cosmetic_outer_fillets_minkowski() {
  minkowski() {
    u_channel_body_outer_union();
    cosmetic_outer_fillets_sphere();
  }
}

module internal_fillet_rounding_minkowski_void() {
  minkowski() {
    open_front_gap_inner_box();
    internal_fillet_rounding_sphere();
  }
}

module u_channel_body_shell() {
  difference() {
    cosmetic_outer_fillets_minkowski();
    internal_fillet_rounding_minkowski_void();
  }
}

module through_holes_union() {
  union() {
    through_hole_cyl_main();
    hole_lead_in_cone_left();
    hole_lead_in_cone_right();
  }
}

module u_channel_body_with_holes() {
  difference() {
    u_channel_body_shell();
    through_holes_union();
  }
}

module end_tabs_union() {
  union() {
    end_tab_left();
    end_tab_right();
  }
}

module u_channel_with_tabs() {
  union() {
    u_channel_body_with_holes();
    end_tabs_union();
  }
}

module u_channel_with_tabs_and_notch() {
  difference() {
    u_channel_with_tabs();
    symmetry_break_notch();
  }
}

// Final Output
u_channel_with_tabs_and_notch();
}
