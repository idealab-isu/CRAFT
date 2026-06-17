// Dimension-calibrated (target: 0.13 x 0.11 x 0.03 mm)
scale([1.080000, 1.165138, 2.461538])
{
// Rounded-rectangle keycap/button plate with shallow recessed face pattern
// and a single row of small rectangular protrusions on ONE face.
// All parts are connected; no floating geometry.

// ---------- Parameters (mm) ----------
bbox_L = 0.10;   //[0.05:0.20:0.001]
bbox_W = 0.10;   //[0.05:0.20:0.001]
bbox_H = 0.010;  //[0.002:0.030:0.001]  // plate-like thickness (nonzero so it can be rendered)

corner_r = 0.015; //[0.005:0.03:0.001]

tab_count = 4;    //[2:10:1]
tab_L = 0.016;    //[0.006:0.030:0.001]
tab_W = 0.010;    //[0.004:0.020:0.001]
tab_H = 0.004;    //[0.001:0.012:0.001]
tab_gap = 0.006;  //[0.002:0.020:0.001]
tab_edge_offset = 0.000; //[0.000:0.010:0.001] // 0 => tabs start at the edge

recess_depth = 0.0012;   //[0.0005:0.003:0.0001]
recess_margin = 0.012;   //[0.004:0.03:0.001]
recess_line_W = 0.004;   //[0.001:0.010:0.001]

eps = 0.0005; //[0.0002:0.002:0.0001]
$fn = 64;

// ---------- Helpers ----------
module rounded_rect_2d(L, W, r) {
  r2 = min(r, min(L, W)/2 - eps);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - r2), sy*(W/2 - r2)]) circle(r=r2);
  }
}

module main_body() {
  linear_extrude(height=bbox_H, center=true)
    rounded_rect_2d(bbox_L, bbox_W, corner_r);
}

module face_recess_pattern(z_face) {
  // Cut depth goes inward from that face; ensure it actually intersects the face.
  // z_face is +/- bbox_H/2.
  zc = z_face + (z_face > 0 ? -recess_depth/2 : recess_depth/2);

  union() {
    // Shallow pocket
    translate([0, 0, zc])
      linear_extrude(height=recess_depth + 2*eps, center=true)
        rounded_rect_2d(bbox_L - 2*recess_margin, bbox_W - 2*recess_margin, max(corner_r - recess_margin, 0));

    // Cross lines (same depth; visible as recess edges)
    translate([0, 0, zc])
      cube([bbox_L - 2*(recess_margin + recess_line_W), recess_line_W, recess_depth + 2*eps], center=true);

    translate([0, 0, zc])
      cube([recess_line_W, bbox_W - 2*(recess_margin + recess_line_W), recess_depth + 2*eps], center=true);
  }
}

module protrusion_row_tabs() {
  // Tabs protrude from ONE opposite face: the -Y face.
  // Ensure overlap into the body for connectivity.
  overlap = 0.001;

  pitch = tab_L + tab_gap;
  row_span = (tab_count-1)*pitch + tab_L;

  // Keep tabs within straight portion (avoid rounded corners)
  usable_L = bbox_L - 2*(corner_r + 0.002);
  scale_row = (row_span > usable_L) ? (usable_L / row_span) : 1;

  // Place tabs so their inner edge is slightly inside the -Y face
  y_center = (-bbox_W/2) - tab_W/2 + tab_edge_offset + overlap;

  // Tabs on the bottom (one large face), protruding downward
  z_center = (-bbox_H/2) - tab_H/2 + overlap;

  for (i = [0:tab_count-1]) {
    x_center = (-((tab_count-1)*pitch)/2 + i*pitch) * scale_row;

    translate([x_center, y_center, z_center])
      cube([tab_L*scale_row, tab_W, tab_H], center=true);
  }
}

// ---------- Final Model ----------
difference() {
  union() {
    main_body();
    protrusion_row_tabs();
  }

  // Recess on BOTH large faces (top and bottom)
  face_recess_pattern(+bbox_H/2);
  face_recess_pattern(-bbox_H/2);
}
}
