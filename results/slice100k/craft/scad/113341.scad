// Parameters
L = 60.4; //[30.2:120.8:0.05]
W = 20.55; //[10.275:41.1:0.05]
T = 8.4; //[4.2:16.8:0.05]
tip_L = 10.5; //[5.25:21:0.05]
body_L = 39.4; //[19.7:78.8:0.05]
tip_W = 20.55; //[10.275:41.1:0.05]
body_W = 14.8; //[7.4:29.6:0.05]
fin_out = 2.875; //[1.4375:5.75:0.025]
fin_L = 6.5; //[3.25:13:0.05]
fin_T = 2.4; //[1.2:4.8:0.05]
fin_offset_from_end = 4; //[2:8:0.05]
notch_depth = 1.2; //[0.6:2.4:0.05]
notch_L = 4; //[2:8:0.05]
notch_T = 3; //[1.5:6:0.05]
overlap = 0.8; //[0.5:2:0.05]
chamfer = 0.6; //[0.3:1.2:0.05]
fillet_r = 0.45; //[0.25:1:0.05]
detail_groove_w = 0.8; //[0.4:1.6:0.05]
detail_groove_d = 0.5; //[0.25:1.2:0.05]
detail_groove_margin = 2.2; //[1.1:4.4:0.05]

// Base Shapes
module main_body_rect_prism() {
  translate([0, 0, 0])
    cube([body_L, body_W, T], center=true);
}

module end_tip_wedge_left() {
  translate([-body_L/2 - tip_L/2 + overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=tip_L, r1=tip_W/2, r2=0, center=true);
}

module end_tip_wedge_right() {
  translate([body_L/2 + tip_L/2 - overlap, 0, 0])
    rotate([0, -90, 0])
      cylinder(h=tip_L, r1=tip_W/2, r2=0, center=true);
}

module side_fin_step_left_pos() {
  translate([-L/2 + fin_offset_from_end + fin_L/2, body_W/2 + fin_out/2 - overlap, T/2 - fin_T/2])
    cube([fin_L, fin_out, fin_T], center=true);
}

module side_fin_step_left_neg() {
  translate([-L/2 + fin_offset_from_end + fin_L/2, -(body_W/2 + fin_out/2 - overlap), T/2 - fin_T/2])
    cube([fin_L, fin_out, fin_T], center=true);
}

module side_fin_step_right_pos() {
  translate([L/2 - fin_offset_from_end - fin_L/2, body_W/2 + fin_out/2 - overlap, T/2 - fin_T/2])
    cube([fin_L, fin_out, fin_T], center=true);
}

module side_fin_step_right_neg() {
  translate([L/2 - fin_offset_from_end - fin_L/2, -(body_W/2 + fin_out/2 - overlap), T/2 - fin_T/2])
    cube([fin_L, fin_out, fin_T], center=true);
}

module end_notch_relief_left() {
  translate([-L/2 + notch_depth + notch_L/2, 0, T/2 - notch_T/2])
    cube([notch_L, W, notch_T], center=true);
}

module end_notch_relief_right() {
  translate([L/2 - notch_depth - notch_L/2, 0, T/2 - notch_T/2])
    cube([notch_L, W, notch_T], center=true);
}

module surface_detail_lines_groove1() {
  translate([0, W/2 - detail_groove_margin - detail_groove_w/2, T/2 - detail_groove_d/2])
    cube([body_L, detail_groove_w, detail_groove_d], center=true);
}

module surface_detail_lines_groove2() {
  translate([0, -(W/2 - detail_groove_margin - detail_groove_w/2), T/2 - detail_groove_d/2])
    cube([body_L, detail_groove_w, detail_groove_d], center=true);
}

module edge_chamfers_kernel() {
  sphere(r=chamfer);
}

module small_fillet_rounding_kernel() {
  sphere(r=fillet_r);
}

// Operations
module side_fin_step_left_pair() {
  union() {
    side_fin_step_left_pos();
    side_fin_step_left_neg();
  }
}

module side_fin_step_right_pair() {
  union() {
    side_fin_step_right_pos();
    side_fin_step_right_neg();
  }
}

module arrow_raw_union() {
  union() {
    main_body_rect_prism();
    end_tip_wedge_left();
    end_tip_wedge_right();
    side_fin_step_left_pair();
    side_fin_step_right_pair();
  }
}

module arrow_with_notches() {
  difference() {
    arrow_raw_union();
    end_notch_relief_left();
    end_notch_relief_right();
  }
}

module arrow_with_surface_detail_lines() {
  difference() {
    arrow_with_notches();
    surface_detail_lines_groove1();
    surface_detail_lines_groove2();
  }
}

// Final Output
minkowski() {
  arrow_with_surface_detail_lines();
  edge_chamfers_kernel();
}

minkowski() {
  arrow_with_surface_detail_lines();
  small_fillet_rounding_kernel();
}