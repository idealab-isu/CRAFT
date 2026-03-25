// Parameters
L = 79.0; //[39.5:158.0:0.5]
W = 22.15; //[11.0:44.3:0.05]
D = 24.3; //[12.2:48.6:0.1]
wall_t = 2.2; //[1.1:4.4:0.1]
channel_W = 17.75; //[8.9:35.5:0.05]
channel_D = 18.8; //[9.4:37.6:0.1]
mouth_opening_D = 18.8; //[9.4:37.6:0.1]
back_round_r = 10.8; //[5.4:21.6:0.1]
outer_fillet_r = 2.0; //[1.0:4.0:0.1]
hole_d = 4.2; //[2.1:8.4:0.1]
hole_center_from_top = 18.0; //[9.0:36.0:0.5]
hole_center_from_front = 12.15; //[6.0:24.3:0.05]
eps = 0.8; //[0.2:2.0:0.1]
tab_h = 3.0; //[1.5:6.0:0.1]
tab_d = 2.0; //[1.0:4.0:0.1]
tab_w = 4.0; //[2.0:8.0:0.1]
small_internal_fillet_r = 1.0; //[0.5:2.0:0.1]
chamfer_r = 0.8; //[0.3:2.0:0.1]

// Base Shapes
module u_channel_body_outer_box() {
  cube([W, D, L], center=true);
}

module internal_channel_void_box() {
  translate([0, (D - channel_D)/2 - eps, 0])
    cube([channel_W, channel_D, L + 2*eps], center=true);
}

module open_front_mouth_cut_box() {
  translate([0, -D/2 + (mouth_opening_D)/2 - eps, 0])
    cube([W + 2*eps, mouth_opening_D + 2*eps, L + 2*eps], center=true);
}

module side_through_hole_cyl() {
  rotate([0, 90, 0])
    cylinder(h=W + 2*eps, r=hole_d/2, center=true);
}

module top_front_tab_left_box() {
  translate([-(W/2 - tab_w/2), -D/2 + tab_d/2 - eps, L/2 - tab_h/2 - eps])
    cube([tab_w, tab_d, tab_h], center=true);
}

module top_front_tab_right_box() {
  translate([(W/2 - tab_w/2), -D/2 + tab_d/2 - eps, L/2 - tab_h/2 - eps])
    cube([tab_w, tab_d, tab_h], center=true);
}

module outer_rounding_sphere() {
  sphere(r=outer_fillet_r, center=true);
}

module back_rounding_sphere() {
  sphere(r=back_round_r, center=true);
}

module small_internal_fillet_sphere() {
  sphere(r=small_internal_fillet_r, center=true);
}

module chamfer_soften_sphere() {
  sphere(r=chamfer_r, center=true);
}

// Operations
module u_channel_body_with_tabs_union() {
  union() {
    u_channel_body_outer_box();
    top_front_tab_left_box();
    top_front_tab_right_box();
  }
}

module internal_channel_void_small_fillet() {
  minkowski() {
    internal_channel_void_box();
    small_internal_fillet_sphere();
  }
}

module u_channel_body_hollowed() {
  difference() {
    u_channel_body_with_tabs_union();
    internal_channel_void_small_fillet();
    open_front_mouth_cut_box();
  }
}

module side_through_hole_left_pos() {
  translate([0, -D/2 + hole_center_from_front, L/2 - hole_center_from_top])
    side_through_hole_cyl();
}

module side_through_hole_right_pos() {
  mirror([1, 0, 0])
    side_through_hole_left_pos();
}

module u_channel_body_with_holes() {
  difference() {
    u_channel_body_hollowed();
    side_through_hole_left_pos();
    side_through_hole_right_pos();
  }
}

module outer_perimeter_fillet_rounding() {
  minkowski() {
    u_channel_body_with_holes();
    outer_rounding_sphere();
  }
}

module outer_back_rounding_fillets() {
  minkowski() {
    outer_perimeter_fillet_rounding();
    back_rounding_sphere();
  }
}

module extra_edge_chamfers() {
  minkowski() {
    outer_back_rounding_fillets();
    chamfer_soften_sphere();
  }
}

// Final Output
extra_edge_chamfers();