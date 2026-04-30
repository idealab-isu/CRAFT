// Seven-segment LED display module (single digit) - self contained
// Units: mm

$fn=32;

// -------------------- Parameters --------------------
primary_dimension = 12.7; //[6.35:25.4:0.1]
body_W = 12.7; //[6.35:25.4:0.1]
body_H = 19.0; //[9.5:38.0:0.1]
body_T = 8.2;  //[4.1:16.4:0.1]

digit_W = 7.2;  //[3.6:14.4:0.1]
digit_H = 12.7; //[6.35:25.4:0.1]
seg_W = 1.2;    //[0.6:2.4:0.05]
digit_depth = 0.6; //[0.3:1.2:0.05]

pin_rows = 2; //[2:2:1]
pin_cols = 5; //[5:5:1]
pin_pitch_X = 2.54; //[1.27:5.08:0.01]
pin_pitch_Y = 2.54; //[1.27:5.08:0.01]
pin_D = 0.5; //[0.25:1.0:0.01]
pin_L = 3.5; //[1.75:7.0:0.1]
pin_inset_X = 1.0; //[0.5:2.0:0.05]
pin_inset_Y = 1.0; //[0.5:2.0:0.05]

edge_fillet_r = 0.6; //[0.3:1.2:0.05]
rear_cavity_depth = 2.0; //[1.0:4.0:0.1]
rear_cavity_margin = 1.2; //[0.6:2.4:0.05]

polarity_mark_r = 0.6; //[0.3:1.2:0.05]
decimal_point_r = 0.7; //[0.35:1.4:0.05]

overlap = 0.8; //[0.5:2.0:0.1]

// Sketch indicates ~1.2mm visible pin length below body
pin_visible_below = 1.2;

// -------------------- Helpers --------------------
module place(pos=[0,0,0], rot=[0,0,0]) {
  translate(pos) rotate(rot) children();
}

module box_center(sz=[1,1,1]) { cube(sz, center=true); }

module cyl_center(r=1, h=1) { cylinder(r=r, h=h, center=true); }

module cone_center(r=1, h=1) { cylinder(r1=r, r2=0, h=h, center=true); }

// -------------------- Base shapes (as modules) --------------------
module main_body() {
  place([0,0,0],[0,0,0]) box_center([body_W, body_T, body_H]);
}

module digit_window_outline() {
  place([0, body_T/2 - digit_depth/2 + overlap/2, 0],[0,0,0])
    box_center([digit_W, digit_depth, digit_H]);
}

module seg_top() {
  place([0, body_T/2 - digit_depth/2 + overlap/2, digit_H/2 - seg_W/2],[0,0,0])
    box_center([digit_W - 2*seg_W, digit_depth, seg_W]);
}

module seg_mid() {
  place([0, body_T/2 - digit_depth/2 + overlap/2, 0],[0,0,0])
    box_center([digit_W - 2*seg_W, digit_depth, seg_W]);
}

module seg_bot() {
  place([0, body_T/2 - digit_depth/2 + overlap/2, -digit_H/2 + seg_W/2],[0,0,0])
    box_center([digit_W - 2*seg_W, digit_depth, seg_W]);
}

module seg_ul() {
  place([-digit_W/2 + seg_W/2, body_T/2 - digit_depth/2 + overlap/2, digit_H/4 + seg_W/2],[0,0,0])
    box_center([seg_W, digit_depth, digit_H/2 - 1.5*seg_W]);
}

module seg_ur() {
  place([ digit_W/2 - seg_W/2, body_T/2 - digit_depth/2 + overlap/2, digit_H/4 + seg_W/2],[0,0,0])
    box_center([seg_W, digit_depth, digit_H/2 - 1.5*seg_W]);
}

module seg_ll() {
  place([-digit_W/2 + seg_W/2, body_T/2 - digit_depth/2 + overlap/2, -digit_H/4 - seg_W/2],[0,0,0])
    box_center([seg_W, digit_depth, digit_H/2 - 1.5*seg_W]);
}

module seg_lr() {
  place([ digit_W/2 - seg_W/2, body_T/2 - digit_depth/2 + overlap/2, -digit_H/4 - seg_W/2],[0,0,0])
    box_center([seg_W, digit_depth, digit_H/2 - 1.5*seg_W]);
}

module decimal_point() {
  place([digit_W/2 - seg_W, body_T/2 - digit_depth/2 + overlap/2, -digit_H/2 + 1.5*seg_W],[90,0,0])
    cyl_center(r=decimal_point_r, h=digit_depth);
}

module polarity_mark() {
  place([-body_W/2 + 2*polarity_mark_r, body_T/2 - digit_depth/2 + overlap/2, -body_H/2 + 2*polarity_mark_r],[90,0,0])
    cyl_center(r=polarity_mark_r, h=digit_depth);
}

module rear_cavity() {
  place([0, -body_T/2 + rear_cavity_depth/2 - overlap/2, 0],[0,0,0])
    box_center([body_W - 2*rear_cavity_margin, rear_cavity_depth, body_H - 2*rear_cavity_margin]);
}

module edge_chamfer_x_pos() {
  place([ body_W/2 - edge_fillet_r/2, 0, 0],[0,0,45])
    box_center([edge_fillet_r, body_T + overlap, body_H + overlap]);
}

module edge_chamfer_x_neg() {
  place([-body_W/2 + edge_fillet_r/2, 0, 0],[0,0,45])
    box_center([edge_fillet_r, body_T + overlap, body_H + overlap]);
}

module edge_chamfer_z_pos() {
  place([0, 0,  body_H/2 - edge_fillet_r/2],[45,0,0])
    box_center([body_W + overlap, body_T + overlap, edge_fillet_r]);
}

module edge_chamfer_z_neg() {
  place([0, 0, -body_H/2 + edge_fillet_r/2],[45,0,0])
    box_center([body_W + overlap, body_T + overlap, edge_fillet_r]);
}

// Pins: positioned under body (along -Z), arranged 5x2
module pin_one_at(x=0, y=0) {
  // Place pins near bottom face, inset slightly from front/back and sides
  // Use sketch: pins extend ~1.2mm below body; keep total pin length param for realism
  pin_total = pin_L;
  zc = -body_H/2 - pin_total/2 + overlap/2;

  place([x, y, zc],[0,0,0])
    cyl_center(r=pin_D/2, h=pin_total + overlap);

  // Tip chamfer (simple cone)
  place([x, y, -body_H/2 - pin_total + pin_D/2],[180,0,0])
    cone_center(r=pin_D/2, h=pin_D);
}

module pin_grid_5x2_full() {
  // Compute grid extents
  x0 = -(pin_pitch_X*(pin_cols-1))/2;
  y0 = -(pin_pitch_Y*(pin_rows-1))/2;

  // Inset from body edges (apply by shifting grid so outer pins are inset)
  // Outer pin x positions span: x0 .. x0 + (pin_cols-1)*pitch
  // Ensure inset by clamping within body_W/2 - pin_inset_X
  // We'll center grid and then, if needed, scale pitch slightly? Avoid; just trust params.
  for (r = [0:pin_rows-1])
    for (c = [0:pin_cols-1]) {
      x = x0 + c*pin_pitch_X;
      y = y0 + r*pin_pitch_Y;

      // Apply front/back inset by shifting rows toward center if needed
      // Keep symmetric: just offset both rows inward by (pin_inset_Y - pin_pitch_Y/2) if positive
      inset_shift = max(0, pin_inset_Y - pin_pitch_Y/2);
      y = (y >= 0) ? (y - inset_shift) : (y + inset_shift);

      // Apply side inset similarly (rarely needed with 2.54 pitch on 12.7 body)
      x_span = (pin_pitch_X*(pin_cols-1))/2;
      max_x_allowed = body_W/2 - pin_inset_X;
      if (x_span > max_x_allowed) {
        // If too wide, compress positions slightly (simple linear scale)
        s = max_x_allowed / x_span;
        x = x * s;
      }

      pin_one_at(x, y);
    }
}

// -------------------- Operations (as modules) --------------------
module seven_segments_geometry() {
  union() {
    seg_top();
    seg_mid();
    seg_bot();
    seg_ul();
    seg_ur();
    seg_ll();
    seg_lr();
  }
}

module digit_recess_all() {
  union() {
    digit_window_outline();
    seven_segments_geometry();
    decimal_point();
    polarity_mark();
  }
}

module body_edge_fillets() {
  union() {
    edge_chamfer_x_pos();
    edge_chamfer_x_neg();
    edge_chamfer_z_pos();
    edge_chamfer_z_neg();
  }
}

module main_body_shaped() {
  difference() {
    main_body();
    digit_recess_all();
    rear_cavity();
    body_edge_fillets();
  }
}

module pins_with_chamfers() {
  // Position pins so they protrude ~pin_visible_below below body, regardless of pin_L
  // Achieve by shifting pins upward/downward along Z.
  // Current pin placement uses pin_L; adjust so bottom tip is at -body_H/2 - pin_visible_below.
  // Bottom tip approx at (-body_H/2 - pin_L). Shift by (pin_L - pin_visible_below).
  z_shift = (pin_L - pin_visible_below);

  translate([0,0,z_shift])
    pin_grid_5x2_full();
}

module complete_module() {
  union() {
    color([0.08,0.08,0.09]) main_body_shaped();     // black epoxy/plastic
    color([0.75,0.75,0.77]) pins_with_chamfers();   // tinned leads
  }
}

// -------------------- Final output --------------------
complete_module();