// Parameters
L = 78.5; //[39.25:157:0.1]
bbox_X = 19.5; //[9.75:39:0.01]
bbox_Y = 18.88; //[9.44:37.76:0.01]
outer_Rx = 9.75; //[4.875:19.5:0.01]
outer_Ry = 9.44; //[4.72:18.88:0.01]
bore_D = 12; //[6:24:0.1]
slit_W = 2.2; //[1.1:4.4:0.05]
notch_depth = 0.8; //[0.4:1.6:0.05]
notch_height = 6; //[3:12:0.1]
notch_spacing = 8; //[4:16:0.1]
notch_z0 = 18; //[0:36:0.1]
eps = 0.8; //[0.5:2:0.1]
outer_fillet_r = 0.6; //[0.3:1.2:0.05]
edge_chamfer = 0.8; //[0.4:1.6:0.05]
bore_taper_L = 2.5; //[1.25:5:0.1]
bore_taper_deltaD = 1.2; //[0.6:2.4:0.1]

// Base Shapes
module bs_outer_bbox_box() {
  cube([bbox_X, bbox_Y, L], center=true);
}

module bs_outer_round_core() {
  cylinder(h=L, r=min(outer_Rx, outer_Ry), center=true);
}

module bs_inner_bore() {
  cylinder(h=L + 2*eps, r=bore_D/2, center=true);
}

module bs_full_length_slit() {
  translate([outer_Rx - slit_W/2 + eps, 0, 0])
    cube([slit_W, bbox_Y + 2*eps, L + 2*eps], center=true);
}

module bs_notch(position_z) {
  translate([bore_D/2 + (notch_depth + eps)/2 - eps, 0, position_z])
    cube([notch_depth + eps, slit_W + 2*eps, notch_height], center=true);
}

module bs_bore_taper_top() {
  translate([0, 0, L/2 - bore_taper_L/2 + eps])
    rotate([180, 0, 0])
    cylinder(h=bore_taper_L, r1=bore_D/2 + bore_taper_deltaD/2, r2=bore_D/2, center=true);
}

module bs_bore_taper_bottom() {
  translate([0, 0, -L/2 + bore_taper_L/2 - eps])
    cylinder(h=bore_taper_L, r1=bore_D/2 + bore_taper_deltaD/2, r2=bore_D/2, center=true);
}

module bs_edge_chamfer_top() {
  translate([0, 0, L/2 - edge_chamfer/2 + eps])
    rotate([180, 0, 0])
    cylinder(h=edge_chamfer, r1=min(outer_Rx, outer_Ry) + edge_chamfer, r2=min(outer_Rx, outer_Ry), center=true);
}

module bs_edge_chamfer_bottom() {
  translate([0, 0, -L/2 + edge_chamfer/2 - eps])
    cylinder(h=edge_chamfer, r1=min(outer_Rx, outer_Ry) + edge_chamfer, r2=min(outer_Rx, outer_Ry), center=true);
}

module bs_outer_fillet_kernel() {
  sphere(r=outer_fillet_r);
}

// Operations
module op_outer_body_raw() {
  intersection() {
    bs_outer_round_core();
    bs_outer_bbox_box();
  }
}

module op_internal_relief_notches() {
  union() {
    bs_notch(notch_z0);
    bs_notch(notch_z0 + notch_spacing);
    bs_notch(notch_z0 + 2*notch_spacing);
  }
}

module op_body_minus_bore() {
  difference() {
    op_outer_body_raw();
    bs_inner_bore();
  }
}

module op_body_minus_bore_and_slit() {
  difference() {
    op_body_minus_bore();
    bs_full_length_slit();
  }
}

module op_body_minus_bore_slit_and_notches() {
  difference() {
    op_body_minus_bore_and_slit();
    op_internal_relief_notches();
  }
}

module op_body_minus_internal_and_chamfers() {
  difference() {
    op_body_minus_bore_slit_and_notches();
    bs_bore_taper_top();
    bs_bore_taper_bottom();
    bs_edge_chamfer_top();
    bs_edge_chamfer_bottom();
  }
}

module op_small_outer_fillet() {
  minkowski() {
    op_body_minus_internal_and_chamfers();
    bs_outer_fillet_kernel();
  }
}

// Final Output
op_small_outer_fillet();