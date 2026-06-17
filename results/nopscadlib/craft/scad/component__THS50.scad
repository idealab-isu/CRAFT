// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

// Robust minimums to avoid degenerate/blank renders
eps = 0.1;
L = max(body_length, eps);
W = max(body_width,  eps);
H = max(body_height, eps);

// Small overlap to guarantee connectivity between parts
overlap = max(min(L, min(W, H)) * 0.02, 0.5);

// Main Body Module
module main_body() {
  cube([L, W, H], center=true);
}

// Connected feature: a top rib (adds visible 3D detail, stays connected)
module top_rib() {
  rib_h = max(H * 0.35, eps);
  rib_w = max(W * 0.35, eps);
  rib_l = max(L * 0.70, eps);

  translate([0, 0, H/2 + rib_h/2 - overlap])
    cube([rib_l, rib_w, rib_h], center=true);
}

// Final Model (one connected solid)
color([0.85, 0.85, 0.8])
union() {
  main_body();
  top_rib();
}