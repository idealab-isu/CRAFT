// Dimension-calibrated (target: 36.17 x 55.53 x 8.66 mm)
scale([0.974962, 0.954786, 0.847160])
{
// Parameters
L = 55.53; //[27.765:111.06:0.01]
W = 36.17; //[18.085:72.34:0.01]
T = 8.66; //[4.33:17.32:0.01]
tip_width = 0.6; //[0.3:1.2:0.01]
flange_w = 3.0; //[1.5:6.0:0.1]
flange_h = 1.6; //[0.8:3.2:0.1]
end_lip_len = 6.0; //[3.0:12.0:0.1]
end_lip_h = 2.0; //[1.0:4.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
chamfer = 0.8; //[0.3:1.6:0.1]
fillet_r = 0.9; //[0.3:1.8:0.1]
tip_flat_len = 1.2; //[0.6:2.4:0.1]

// Base Shapes
module tapered_wedge_main_body() {
  linear_extrude(height=T) {
    polygon(points=[
      [-L/2, -W/2],
      [-L/2, W/2],
      [L/2, tip_width/2],
      [L/2, -tip_width/2]
    ]);
  }
}

module longitudinal_edge_step_flange() {
  linear_extrude(height=flange_h) {
    polygon(points=[
      [-L/2, W/2 - flange_w],
      [-L/2, W/2],
      [L/2, tip_width/2],
      [L/2, tip_width/2 - flange_w]
    ]);
  }
}

module wide_end_perpendicular_end_face_lip() {
  translate([-L/2 + end_lip_len/2 - overlap, 0, T/2 - end_lip_h/2])
    cube([end_lip_len, W, end_lip_h], center=true);
}

module small_tip_flattening_cutter() {
  translate([L/2 - tip_flat_len/2, 0, 0])
    cube([tip_flat_len, W*2, T*2], center=true);
}

module edge_chamfer_cutter_top_long() {
  rotate([0, 90, 0])
    translate([0, 0, T/2 - chamfer])
      linear_extrude(height=L + 2*overlap) {
        polygon(points=[
          [0, 0],
          [chamfer, 0],
          [0, chamfer]
        ]);
      }
}

module edge_chamfer_cutter_top_short() {
  rotate([-90, 0, 0])
    translate([-L/2 + end_lip_len - overlap, 0, T/2 - chamfer])
      linear_extrude(height=W + 2*overlap) {
        polygon(points=[
          [0, 0],
          [chamfer, 0],
          [0, chamfer]
        ]);
      }
}

module fillet_roundovers_sphere() {
  sphere(r=fillet_r);
}

// Operations
module main_plus_flange() {
  union() {
    tapered_wedge_main_body();
    longitudinal_edge_step_flange();
  }
}

module main_flange_plus_lip() {
  union() {
    main_plus_flange();
    wide_end_perpendicular_end_face_lip();
  }
}

module with_tip_flattening() {
  difference() {
    main_flange_plus_lip();
    small_tip_flattening_cutter();
  }
}

module with_edge_chamfers() {
  difference() {
    with_tip_flattening();
    edge_chamfer_cutter_top_long();
    edge_chamfer_cutter_top_short();
  }
}

// Final Output
minkowski() {
  with_edge_chamfers();
  fillet_roundovers_sphere();
}
}
