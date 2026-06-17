// Parameters
bbox_x = 0.03; //[0.015:0.06:0.001]
bbox_y = 0.04; //[0.02:0.08:0.001]
bbox_z = 0.01; //[0.005:0.02:0.001]
plate_thk = 0.01; //[0.005:0.02:0.001]
body_w = 0.022; //[0.011:0.044:0.001]
body_l = 0.026; //[0.013:0.052:0.001]
flange_w = 0.03; //[0.015:0.06:0.001]
flange_l = 0.014; //[0.007:0.028:0.001]
chamfer = 0.004; //[0.002:0.008:0.001]
hole_d = 0.004; //[0.002:0.008:0.001]
hole_edge_offset_x = 0.004; //[0.002:0.008:0.001]
hole_edge_offset_y = 0.004; //[0.002:0.008:0.001]
v_depth = 0.001; //[0.0005:0.002:0.0005]
v_len = 0.012; //[0.006:0.024:0.001]
v_w = 0.006; //[0.003:0.012:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
countersink_d = 0.006; //[0.003:0.012:0.001]
countersink_depth = 0.002; //[0.001:0.004:0.0005]
fillet_r = 0.001; //[0.0005:0.002:0.0005]

// Base Shapes
module plate_body_main() {
  translate([0, flange_l/2, 0])
    cube([body_w, body_l, plate_thk], center=true);
}

module plate_body_flange() {
  translate([0, -body_l/2 + flange_l/2, 0])
    cube([flange_w, flange_l, plate_thk], center=true);
}

module chamfer_wedge_left() {
  translate([-body_w/2 + chamfer/2, flange_l + body_l/2 - chamfer/2, 0])
    rotate([0, 0, 45])
      cube([chamfer, chamfer, plate_thk + 2*overlap], center=true);
}

module chamfer_wedge_right() {
  translate([body_w/2 - chamfer/2, flange_l + body_l/2 - chamfer/2, 0])
    rotate([0, 0, 45])
      cube([chamfer, chamfer, plate_thk + 2*overlap], center=true);
}

module through_hole_1() {
  translate([-flange_w/2 + hole_edge_offset_x, -body_l/2 + hole_edge_offset_y, 0])
    cylinder(h=plate_thk + 2*overlap, r=hole_d/2, center=true);
}

module through_hole_2() {
  translate([flange_w/2 - hole_edge_offset_x, -body_l/2 + hole_edge_offset_y, 0])
    cylinder(h=plate_thk + 2*overlap, r=hole_d/2, center=true);
}

module counterbore_1() {
  translate([-flange_w/2 + hole_edge_offset_x, -body_l/2 + hole_edge_offset_y, plate_thk/2 - (countersink_depth + overlap)/2])
    cylinder(h=countersink_depth + overlap, r=countersink_d/2, center=true);
}

module counterbore_2() {
  translate([flange_w/2 - hole_edge_offset_x, -body_l/2 + hole_edge_offset_y, plate_thk/2 - (countersink_depth + overlap)/2])
    cylinder(h=countersink_depth + overlap, r=countersink_d/2, center=true);
}

module v_arrow_face_feature_1() {
  translate([0, flange_l/2 + body_l*0.15, plate_thk/2 - (v_depth + overlap)/2])
    linear_extrude(height=v_depth + overlap, center=true)
      polygon(points=[[-v_w/2, -v_len/2], [v_w/2, -v_len/2], [0, v_len/2]]);
}

module v_arrow_face_feature_2() {
  translate([0, flange_l/2 + body_l*0.35, plate_thk/2 - (v_depth + overlap)/2])
    rotate([0, 0, 180])
      linear_extrude(height=v_depth + overlap, center=true)
        polygon(points=[[-v_w/2, -v_len/2], [v_w/2, -v_len/2], [0, v_len/2]]);
}

module edge_fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module plate_body_with_stepped_flange() {
  union() {
    plate_body_main();
    plate_body_flange();
  }
}

module chamfered_end_corners() {
  difference() {
    plate_body_with_stepped_flange();
    chamfer_wedge_left();
    chamfer_wedge_right();
  }
}

module holes_and_counterbores() {
  difference() {
    chamfered_end_corners();
    through_hole_1();
    through_hole_2();
    counterbore_1();
    counterbore_2();
  }
}

module face_v_features_recessed() {
  difference() {
    holes_and_counterbores();
    v_arrow_face_feature_1();
    v_arrow_face_feature_2();
  }
}

module edge_fillets() {
  minkowski() {
    face_v_features_recessed();
    edge_fillet_sphere();
  }
}

// Final Output
edge_fillets();