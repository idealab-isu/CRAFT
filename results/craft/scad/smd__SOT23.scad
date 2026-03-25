// SMD package overall size (X,Y,Z) = [3, 1.4, 1.0]
// One connected solid. No floating parts. All placements are formula-based.

body_length = 3.0;
body_width  = 1.4;
body_height = 1.0;

// Frame (blue) thickness around the inner (orange) area as seen in renders
frame_wall = 0.18;          // per-side wall thickness in X/Y
inner_top_recess = 0.06;    // depth of top recess (keeps outer silhouette same)

// Small rectangular feature (blue) that appears on different sides in left/right views
feat_x = 0.55;
feat_y = 0.35;
feat_z = 0.22;
feat_inset = 0.10;          // inset from the inner edge
feat_end_offset = 0.35;     // distance from end along length

eps = 0.02;

// Derived inner pocket size (clamped)
inner_len = max(eps, body_length - 2*frame_wall);
inner_wid = max(eps, body_width  - 2*frame_wall);
inner_dep = max(eps, inner_top_recess);

// Main outer body
module outer_body() {
  cube([body_length, body_width, body_height], center=true);
}

// Top recess to create the "frame" look in front/back/left/right views
module top_recess() {
  // Pocket starts at top surface and goes downward by inner_dep
  zc = body_height/2 - inner_dep/2 + eps;
  translate([0, 0, zc])
    cube([inner_len, inner_wid, inner_dep + 2*eps], center=true);
}

// Small feature on the recessed top surface.
// Positioned so it is visible in:
// - Front/Back: near left/right end (X direction)
// - Left/Right: near top/bottom (Y direction) by swapping Y sign
module top_feature(y_side=1, x_side=-1) {
  // Place on top surface, slightly embedded for watertight union
  zc = body_height/2 - inner_dep - feat_z/2 + eps;

  // X: near one end, inside the inner pocket
  x_inner_edge = x_side * (inner_len/2);
  xc = x_inner_edge + (-x_side) * (feat_end_offset + feat_x/2);

  // Y: near one side of the inner pocket (changes between left/right views)
  y_inner_edge = y_side * (inner_wid/2);
  yc = y_inner_edge - y_side * (feat_inset + feat_y/2);

  translate([xc, yc, zc])
    cube([feat_x, feat_y, feat_z + 2*eps], center=true);
}

module smd() {
  union() {
    difference() {
      outer_body();
      top_recess();
    }
    // Two features to match the ambiguous side-view behavior:
    // one near (-X, +Y) and one near (+X, -Y)
    top_feature(y_side= 1, x_side=-1);
    top_feature(y_side=-1, x_side= 1);
  }
}

smd();