$fn = 64;

size = [3, 1.4, 1.0]; // [X, Y, Z] in mm

module smd_body(sz=[3,1.4,1.0]) {
  // Simple SMD package body with slight edge rounding via minkowski
  r = min(sz[0], sz[1], sz[2]) * 0.08;
  r = max(0.02, min(r, 0.15));
  minkowski() {
    cube([sz[0]-2*r, sz[1]-2*r, sz[2]-2*r], center=true);
    sphere(r=r);
  }
}

module smd_terminals(sz=[3,1.4,1.0]) {
  // Two end terminals (pads) on the sides along X
  pad_len = sz[0] * 0.18;
  pad_thk = sz[2] * 0.22;
  pad_w   = sz[1] * 0.92;

  for (sx = [-1, 1]) {
    translate([sx*(sz[0]/2 - pad_len/2), 0, -sz[2]/2 + pad_thk/2])
      cube([pad_len, pad_w, pad_thk], center=true);
  }
}

module smd(sz=[3,1.4,1.0]) {
  // Body
  color([0.08, 0.08, 0.09]) smd_body(sz);

  // Terminals
  color([0.75, 0.75, 0.78]) smd_terminals(sz);

  // Subtle top marking
  mark_len = sz[0]*0.35;
  mark_w   = sz[1]*0.18;
  mark_thk = sz[2]*0.03;
  color([0.9, 0.9, 0.9])
    translate([0, 0, sz[2]/2 - mark_thk/2])
      cube([mark_len, mark_w, mark_thk], center=true);
}

smd(size);