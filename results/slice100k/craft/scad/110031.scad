// Parameters
bbox_X = 18.92; //[9.46:37.84:0.01]
bbox_Y = 11.0; //[5.5:22.0:0.01]
bbox_Z = 8.76; //[4.38:17.52:0.01]
barrel_len = 11.0; //[5.5:22.0:0.01]
barrel_d = 6.6; //[3.3:13.2:0.01]
stem_len = 18.92; //[9.46:37.84:0.01]
stem_d = 5.2; //[2.6:10.4:0.01]
collar_d = 7.6; //[3.8:15.2:0.01]
collar_thk = 2.0; //[1.0:4.0:0.01]
flange_thk = 1.2; //[0.6:2.4:0.01]
flange_w = 11.0; //[5.5:22.0:0.01]
flange_h = 8.76; //[4.38:17.52:0.01]
prong_len = 4.2; //[2.1:8.4:0.01]
prong_thk = 1.8; //[0.9:3.6:0.01]
slot_w = 2.2; //[1.1:4.4:0.01]
slot_depth = 4.0; //[2.0:8.0:0.01]
tip_chamfer = 0.6; //[0.3:1.2:0.01]
overlap = 0.8; //[0.3:2.0:0.01]
micro_chamfer = 0.3; //[0.1:0.8:0.01]
fillet_r = 0.4; //[0.2:1.0:0.01]

// Base Shapes
module stem_cylinder() {
  rotate([0, 90, 0])
    translate([0, 0, 0])
      cylinder(r=stem_d/2, h=stem_len, center=true);
}

module barrel_cylinder() {
  rotate([90, 0, 0])
    translate([0, 0, 0])
      cylinder(r=barrel_d/2, h=barrel_len, center=true);
}

module junction_collar_shoulder() {
  rotate([0, 90, 0])
    translate([0, 0, 0])
      cylinder(r=collar_d/2, h=collar_thk, center=true);
}

module flange_stop_plate() {
  translate([-(stem_len/2) + (flange_thk/2) - overlap, 0, 0])
    cube([flange_thk, flange_w, flange_h], center=true);
}

module fork_prong_top() {
  translate([(stem_len/2) - (prong_len/2) + overlap, (slot_w/2) + (prong_thk/2), 0])
    cube([prong_len, prong_thk, barrel_d], center=true);
}

module fork_prong_bottom() {
  translate([(stem_len/2) - (prong_len/2) + overlap, -((slot_w/2) + (prong_thk/2)), 0])
    cube([prong_len, prong_thk, barrel_d], center=true);
}

module fork_u_slot_cut() {
  translate([(stem_len/2) - (slot_depth/2) + overlap, 0, 0])
    cube([slot_depth, slot_w, barrel_d + 2*overlap], center=true);
}

module prong_tip_chamfer_top() {
  rotate([0, 0, 45])
    translate([(stem_len/2) - (tip_chamfer/2), (slot_w/2) + (prong_thk/2), 0])
      cube([tip_chamfer, prong_thk + 2*overlap, barrel_d + 2*overlap], center=true);
}

module prong_tip_chamfer_bottom() {
  rotate([0, 0, -45])
    translate([(stem_len/2) - (tip_chamfer/2), -((slot_w/2) + (prong_thk/2)), 0])
      cube([tip_chamfer, prong_thk + 2*overlap, barrel_d + 2*overlap], center=true);
}

module barrel_end_faces_trim() {
  translate([0, 0, 0])
    cube([stem_len + 2*overlap, barrel_len + 2*overlap, bbox_Z + 2*overlap], center=true);
}

module stem_end_face_trim() {
  translate([0, 0, 0])
    cube([stem_len + 2*overlap, bbox_Y + 2*overlap, bbox_Z + 2*overlap], center=true);
}

module micro_chamfers_on_flange() {
  rotate([0, 45, 0])
    translate([-(stem_len/2) + flange_thk - (micro_chamfer/2), 0, 0])
      cube([micro_chamfer, flange_w + 2*overlap, flange_h + 2*overlap], center=true);
}

module fillet_kernel_sphere() {
  translate([0, 0, 0])
    sphere(r=fillet_r, center=true);
}

// Operations
module t_core_union() {
  union() {
    stem_cylinder();
    barrel_cylinder();
    junction_collar_shoulder();
    flange_stop_plate();
    fork_prong_top();
    fork_prong_bottom();
  }
}

module fork_prongs_u_slot() {
  difference() {
    t_core_union();
    fork_u_slot_cut();
  }
}

module prong_tip_chamfers() {
  difference() {
    fork_prongs_u_slot();
    prong_tip_chamfer_top();
    prong_tip_chamfer_bottom();
  }
}

module micro_chamfered_flange() {
  difference() {
    prong_tip_chamfers();
    micro_chamfers_on_flange();
  }
}

module small_edge_fillets() {
  minkowski() {
    micro_chamfered_flange();
    fillet_kernel_sphere();
  }
}

module bounded_model() {
  intersection() {
    small_edge_fillets();
    barrel_end_faces_trim();
    stem_end_face_trim();
  }
}

// Final Output
bounded_model();