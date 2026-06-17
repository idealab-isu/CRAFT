// Parameters
body_L = 8.7; //[4.35:17.4:0.05]
body_W = 3.9; //[1.95:7.8:0.05]
body_H = 1.25; //[0.625:2.5:0.05]
edge_fillet_r = 0.25; //[0.1:0.6:0.05]
top_chamfer = 0.2; //[0.05:0.5:0.05]
polarity_mark_r = 0.35; //[0.15:0.8:0.05]
polarity_mark_h = 0.08; //[0.03:0.2:0.01]
pad_L = 1.2; //[0.6:2.4:0.05]
pad_W = 3.2; //[1.6:3.9:0.05]
pad_T = 0.08; //[0.03:0.2:0.01]
overlap = 0.8; //[0.5:2.0:0.1]

// Base shapes
module smd_body_core_box() {
  cube([body_L - 2*edge_fillet_r, body_W - 2*edge_fillet_r, body_H - 2*edge_fillet_r], center=true);
}

module side_fillet_sphere() {
  sphere(r=edge_fillet_r, center=true);
}

module top_chamfer_cut_box() {
  translate([0, 0, body_H/2 - top_chamfer/2])
    cube([body_L + 2*overlap, body_W + 2*overlap, top_chamfer], center=true);
}

module top_chamfer_cut_wedge() {
  translate([0, 0, body_H/2 - top_chamfer])
    rotate([90, 0, 0])
      linear_extrude(height=body_W + 2*overlap, center=true)
        polygon(points=[
          [-(body_L/2 + overlap), 0],
          [(body_L/2 + overlap), 0],
          [(body_L/2 + overlap), top_chamfer],
          [-(body_L/2 + overlap), top_chamfer]
        ]);
}

module polarity_mark_cyl() {
  translate([-(body_L/2 - polarity_mark_r - overlap/2), (body_W/2 - polarity_mark_r - overlap/2), body_H/2 + polarity_mark_h/2 - overlap/2])
    cylinder(r=polarity_mark_r, h=polarity_mark_h, center=true);
}

module metal_pad_left() {
  translate([-(body_L/2 - pad_L/2 + overlap/2), 0, -(body_H/2 - pad_T/2 + overlap/2)])
    cube([pad_L, pad_W, pad_T], center=true);
}

module metal_pad_right() {
  translate([(body_L/2 - pad_L/2 + overlap/2), 0, -(body_H/2 - pad_T/2 + overlap/2)])
    cube([pad_L, pad_W, pad_T], center=true);
}

// Operations
module side_fillet_minkowski() {
  minkowski() {
    smd_body_core_box();
    side_fillet_sphere();
  }
}

module top_chamfer_cut_union() {
  union() {
    top_chamfer_cut_box();
    top_chamfer_cut_wedge();
  }
}

module smd_body() {
  difference() {
    side_fillet_minkowski();
    top_chamfer_cut_union();
  }
}

module metal_pads() {
  union() {
    metal_pad_left();
    metal_pad_right();
  }
}

// Final model
module complete_model() {
  union() {
    smd_body();
    polarity_mark_cyl();
    metal_pads();
  }
}

// Render the complete model
complete_model();