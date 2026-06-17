// SMD package: overall body [L,W,H] = [3, 1.4, 1.0] mm
// One connected solid (pads fused to body with small overlap)

$fn = 48;

// Parameters
body_L = 3.0; //[1.5:6.0:0.1]
body_W = 1.4; //[0.7:2.8:0.1]
body_H = 1.0; //[0.5:2.0:0.1]

pad_L = 0.5; //[0.25:1.0:0.05]
pad_W = 1.1; //[0.6:1.4:0.05]
pad_T = 0.08; //[0.03:0.2:0.01]
pad_overlap = 0.25; //[0.05:0.8:0.05]  // overlap into body to guarantee connectivity

mark_R = 0.18; //[0.08:0.4:0.01]
mark_inset = 0.25; //[0.1:0.6:0.05]
mark_T = 0.05; //[0.02:0.15:0.01]

top_mark_L = 1.6; //[0.8:2.8:0.1]
top_mark_W = 0.5; //[0.2:1.2:0.05]
top_mark_T = 0.03; //[0.01:0.12:0.01]

chamfer = 0.12; //[0.00:0.35:0.01]     // small, safe chamfer
eps = 0.01; //[0.001:0.1:0.001]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);
ch = clamp(chamfer, 0, min(body_L, body_W, body_H)/3);

// Base body with simple edge chamfers (robust; avoids slanted "plane" artifacts)
module body_chamfered() {
  color([0.85, 0.85, 0.8])
  difference() {
    cube([body_L, body_W, body_H], center=true);

    // Cut 4 vertical edges (along Z) using rotated cubes
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*(body_L/2 - ch/2), sy*(body_W/2 - ch/2), 0])
        rotate([0, 0, 45])
          cube([ch*sqrt(2), ch*sqrt(2), body_H + 2*eps], center=true);
    }

    // Light top/bottom edge bevels (along X) to soften silhouette
    for (sz = [-1, 1]) {
      translate([0, 0, sz*(body_H/2 - ch/2)])
        rotate([45, 0, 0])
          cube([body_L + 2*eps, ch*sqrt(2), ch*sqrt(2)], center=true);

      translate([0, 0, sz*(body_H/2 - ch/2)])
        rotate([0, 45, 0])
          cube([ch*sqrt(2), body_W + 2*eps, ch*sqrt(2)], center=true);
    }
  }
}

// Terminations (pads) fused to body
module terminal_pad(side=1) { // side = -1 (left), +1 (right)
  pad_len_total = pad_L + pad_overlap;

  // Place so inner face overlaps into body by pad_overlap
  x_center = side * (body_L/2 - pad_len_total/2 + pad_overlap);

  // Put pad on bottom, slightly intersecting body to ensure union is one solid
  z_center = -body_H/2 + pad_T/2 + eps;

  translate([x_center, 0, z_center])
    color([0.72, 0.45, 0.2])
      cube([pad_len_total, pad_W, pad_T], center=true);
}

module polarity_mark() {
  // Slightly embedded into top surface (not floating)
  translate([-body_L/2 + mark_inset, body_W/2 - mark_inset, body_H/2 - mark_T/2 + eps])
    color([0.2, 0.2, 0.2])
      cylinder(r=mark_R, h=mark_T, center=true);
}

module top_marking() {
  // Slightly embedded into top surface (not floating)
  translate([0, 0, body_H/2 - top_mark_T/2 + eps])
    color([0.2, 0.2, 0.2])
      cube([top_mark_L, top_mark_W, top_mark_T], center=true);
}

// Final output: ONE connected solid
union() {
  body_chamfered();
  terminal_pad(-1);
  terminal_pad(1);
  polarity_mark();
  top_marking();
}