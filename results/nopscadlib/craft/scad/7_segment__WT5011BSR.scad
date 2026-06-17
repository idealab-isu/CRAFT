$fn = 64;

// Target overall body dimensions (W, H, D)
body_W = 12.7;  //[6.35:25.4:0.1]
body_H = 19;    //[9.5:38:0.1]
body_D = 8.2;   //[4.1:16.4:0.1]

// Front bezel + window
bezel_frame = 1.2;          //[0.6:2.4:0.1]
bezel_thickness = 1.0;      //[0.5:2.0:0.1]
window_recess_depth = 0.8;  //[0.4:1.6:0.1]
window_clearance = 0.4;     //[0.2:1.0:0.1]

// Segment geometry (RECESSED cutouts so the 7-seg reads clearly in orthographic views)
segment_recess = 0.9;       //[0.4:2.0:0.1]  // depth of segment cut into front
segment_thickness = 1.6;    //[0.8:3.2:0.1]
segment_margin = 1.6;       //[0.8:3.2:0.1]
segment_gap = 1.2;          //[0.6:2.4:0.1]
segment_end_round = 0.55;   //[0.2:1.2:0.05]  // rounded ends for visible "bars"

// Decimal point (optional recessed)
decimal_r = 1.0;            //[0.5:2.0:0.1]
decimal_recess = 0.9;       //[0.4:2.0:0.1]

// Connectivity overlap (keeps booleans watertight)
overlap = 1.2;              //[0.2:2.0:0.1]

// ---- Derived sizes (clamped) ----
bezel_inner_W = max(0.1, body_W - 2*bezel_frame);
bezel_inner_H = max(0.1, body_H - 2*bezel_frame);

win_W = max(0.1, body_W - 2*(bezel_frame + window_clearance));
win_H = max(0.1, body_H - 2*(bezel_frame + window_clearance));

// Segment lengths inside the window area
seg_len = max(0.1, win_W - 2*segment_margin);
seg_v_len = max(
  0.1,
  (win_H - 2*segment_margin - 3*segment_thickness - 2*segment_gap)/2
);

// ---- Base body ----
module display_body() {
  cube([body_W, body_H, body_D], center=true);
}

// Bezel ring on the front face (connected to body with overlap)
module bezel_ring() {
  translate([0, 0, body_D/2 + bezel_thickness/2 - overlap])
    difference() {
      cube([body_W, body_H, bezel_thickness], center=true);
      cube([bezel_inner_W, bezel_inner_H, bezel_thickness + 2*overlap], center=true);
    }
}

// Window recess (a shallow pocket) to frame the segments
module window_recess() {
  // Cut into the front face; ensure it intersects the body by overlap
  translate([0, 0, body_D/2 - window_recess_depth/2 + overlap/2])
    cube([win_W, win_H, window_recess_depth + overlap], center=true);
}

// Rounded "bar" helper (2D rounded rectangle extruded)
module bar_solid(L, T, H, r) {
  rr = min(r, T/2, L/2);
  linear_extrude(height=H, center=true)
    offset(delta=(T/2 - rr))
      hull() {
        translate([-(L/2-rr), 0]) circle(r=rr);
        translate([ (L/2-rr), 0]) circle(r=rr);
      }
}

// 7 segment CUTTERS (recessed into the front face so it reads as a 7-seg)
module segment_cutters() {
  // Center cutters just inside the front face so they definitely subtract
  zc = body_D/2 - segment_recess/2 + overlap/2;

  // Segment placement within the window area
  y_top =  win_H/2 - segment_margin - segment_thickness/2;
  y_mid =  0;
  y_bot = -y_top;

  x_l = -(win_W/2 - segment_margin - segment_thickness/2);
  x_r =  (win_W/2 - segment_margin - segment_thickness/2);

  // Vertical segment centers (upper and lower)
  y_up =  (segment_thickness + segment_gap)/2;
  y_dn = -(segment_thickness + segment_gap)/2;

  // Horizontal segments: a (top), g (middle), d (bottom)
  translate([0, y_top, zc])
    bar_solid(seg_len, segment_thickness, segment_recess + overlap, segment_end_round);

  translate([0, y_mid, zc])
    bar_solid(seg_len, segment_thickness, segment_recess + overlap, segment_end_round);

  translate([0, y_bot, zc])
    bar_solid(seg_len, segment_thickness, segment_recess + overlap, segment_end_round);

  // Vertical segments: f (upper-left), b (upper-right), e (lower-left), c (lower-right)
  translate([x_l, y_up, zc])
    rotate([0,0,90])
      bar_solid(seg_v_len, segment_thickness, segment_recess + overlap, segment_end_round);

  translate([x_r, y_up, zc])
    rotate([0,0,90])
      bar_solid(seg_v_len, segment_thickness, segment_recess + overlap, segment_end_round);

  translate([x_l, y_dn, zc])
    rotate([0,0,90])
      bar_solid(seg_v_len, segment_thickness, segment_recess + overlap, segment_end_round);

  translate([x_r, y_dn, zc])
    rotate([0,0,90])
      bar_solid(seg_v_len, segment_thickness, segment_recess + overlap, segment_end_round);

  // Decimal point (recessed) inside window area
  dp_x =  win_W/2 - segment_margin - decimal_r;
  dp_y = -win_H/2 + segment_margin + decimal_r;

  translate([dp_x, dp_y, body_D/2 - decimal_recess/2 + overlap/2])
    cylinder(r=decimal_r, h=decimal_recess + overlap, center=true);
}

// Final: ONE connected solid (body + bezel) with recessed window + recessed segments
module complete_model() {
  difference() {
    union() {
      display_body();
      bezel_ring();
    }
    // Cut features into the front face so the 7-segment is clearly visible
    window_recess();
    segment_cutters();
  }
}

complete_model();