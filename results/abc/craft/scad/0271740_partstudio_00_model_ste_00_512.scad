// Dimension-calibrated (target: 0.05 x 0.11 x 0.04 mm)
scale([1.273810, 0.960000, 1.025000])
{
// Compact mounting bracket / clip-like part
// One connected solid, with:
// - Rounded-rect (barrel) main body
// - Rounded holed tab with TWO round through-holes
// - Forked clevis end with U-shaped opening
// - Center diamond through-hole

$fn = 64;

// Parameters (kept from original, small-scale)
L = 0.11; //[0.055:0.22:0.001]
W = 0.05; //[0.025:0.1:0.001]
H = 0.04; //[0.02:0.08:0.001]

body_L = 0.06; //[0.03:0.12:0.001]
body_W = 0.038; //[0.019:0.076:0.001]
body_H = 0.04; //[0.02:0.08:0.001]
body_corner_r = 0.009; //[0.0045:0.018:0.0005]

tab1_L = 0.025; //[0.0125:0.05:0.001]
tab1_W = 0.05; //[0.025:0.1:0.001]
tab1_H = 0.04; //[0.02:0.08:0.001]
tab1_round_r = 0.025; //[0.0125:0.05:0.001]

tab2_L = 0.025; //[0.0125:0.05:0.001]
tab2_W = 0.05; //[0.025:0.1:0.001]
tab2_H = 0.04; //[0.02:0.08:0.001]

clevis_notch_depth = 0.018; //[0.009:0.036:0.001]
clevis_notch_width = 0.022; //[0.011:0.044:0.001]
clevis_prong_thk = 0.014; //[0.007:0.028:0.001]

hole_d = 0.008; //[0.004:0.016:0.0005]
hole_spacing = 0.016; //[0.008:0.032:0.001]
hole_edge_margin = 0.006; //[0.003:0.012:0.0005]

diamond_flat_to_flat = 0.01; //[0.005:0.02:0.0005]
eps = 0.001; //[0.0005:0.002:0.0001]

// ---------- Helpers ----------
module rounded_rect_prism(x, y, z, r) {
  r2 = min(r, x/2, y/2);
  linear_extrude(height=z, center=true)
    offset(r=r2)
      square([x-2*r2, y-2*r2], center=true);
}

// ---------- Main body (barrel / rounded-rect) ----------
module main_body_barrel() {
  rounded_rect_prism(body_L, body_W, body_H, body_corner_r);
}

// ---------- Holed end tab (rounded end + two round through holes) ----------
module end_tab_holed_solid() {
  // Build as: rectangular stem + semicircular end cap (in XY), extruded in Z
  stem_L = max(tab1_L - tab1_W/2, eps);
  x0 = -(body_L/2) - stem_L/2 + eps;                 // stem center x
  xcap = -(body_L/2) - stem_L + tab1_W/2 + eps;      // cap center x

  union() {
    translate([x0, 0, 0])
      cube([stem_L, tab1_W, tab1_H], center=true);

    translate([xcap, 0, 0])
      cylinder(r=tab1_W/2, h=tab1_H, center=true);
  }
}

module fastener_holes() {
  // Place holes on the rounded tab, centered in X near the end, spaced in Y
  stem_L = max(tab1_L - tab1_W/2, eps);
  xcap = -(body_L/2) - stem_L + tab1_W/2 + eps;

  // Keep holes inside the cap with a margin
  xh = xcap + (tab1_W/2 - hole_edge_margin - hole_d/2);

  union() {
    translate([xh,  hole_spacing/2, 0])
      cylinder(d=hole_d, h=tab1_H + 2*eps, center=true);
    translate([xh, -hole_spacing/2, 0])
      cylinder(d=hole_d, h=tab1_H + 2*eps, center=true);
  }
}

// ---------- Clevis end (forked with U-shaped opening) ----------
module end_tab_clevis_solid() {
  // Base block attached to body
  xbase = (body_L/2) + tab2_L/2 - eps;
  translate([xbase, 0, 0])
    cube([tab2_L, tab2_W, tab2_H], center=true);
}

module clevis_u_notch_cut() {
  // U-shaped opening from the far end of the clevis, open to +X
  // Cut = rectangular slot + semicircular end to form a U
  x_far = (body_L/2) + tab2_L - eps;                 // far face x
  x_slot_c = x_far - clevis_notch_depth/2;           // slot center x
  x_round_c = x_far - clevis_notch_depth;            // round end center x

  union() {
    // Rectangular part of the notch
    translate([x_slot_c, 0, 0])
      cube([clevis_notch_depth + 2*eps, clevis_notch_width, tab2_H + 2*eps], center=true);

    // Rounded end of the notch (U bottom)
    translate([x_round_c, 0, 0])
      cylinder(r=clevis_notch_width/2, h=tab2_H + 2*eps, center=true);
  }
}

// ---------- Center diamond through-hole ----------
module center_diamond_through_hole() {
  linear_extrude(height=body_H + 2*eps, center=true)
    polygon(points=[
      [ diamond_flat_to_flat/2, 0],
      [0,  diamond_flat_to_flat/2],
      [-diamond_flat_to_flat/2, 0],
      [0, -diamond_flat_to_flat/2]
    ]);
}

// ---------- Final model ----------
difference() {
  union() {
    main_body_barrel();
    end_tab_holed_solid();
    end_tab_clevis_solid();
  }

  // Cuts
  fastener_holes();
  clevis_u_notch_cut();
  center_diamond_through_hole();
}
}
