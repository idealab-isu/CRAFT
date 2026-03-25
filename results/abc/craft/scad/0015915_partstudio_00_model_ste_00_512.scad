// Dimension-calibrated (target: 0.18 x 0.13 x 0.01 mm)
scale([0.920225, 1.260693, 0.416697])
{
// Vented/stiffened panel: perimeter frame + 3x2 rounded-rect cutouts + two diagonal ribs/webs
// Fixed: diagonal ribs are now guaranteed to be visible and connected (not removed by cutouts),
// by subtracting cutouts first and then adding ribs on top (with slight Z overlap).
// All dimensions in mm.

$fn = 64;

// Overall bounding box target (approx): 0.20 x 0.10 x thin
L = 0.20;
W = 0.10;
T = 0.01;

// Frame
frame_w  = 0.012;
corner_r = 0.004;

// Cutouts (3x2 grid)
cut_cols = 3;
cut_rows = 2;
gap_x    = 0.008;
gap_y    = 0.010;
cut_r    = 0.006;

// Ribs/webs
rib_w         = 0.010;   // slightly wider so they read in orthographic views
rib_angle_deg = 35;

// Robustness / connectivity
overlap = 0.001;         // small overlap for boolean robustness
z_fuse  = 0.002;         // extra rib height to ensure union + visibility

// ---------- helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_rect_2d(sz=[10,10], r=1) {
  rr = clamp(r, 0, min(sz[0], sz[1]) / 2);
  offset(r=rr)
    square([max(0, sz[0]-2*rr), max(0, sz[1]-2*rr)], center=true);
}

module rounded_box(sz=[10,10,1], r=1) {
  linear_extrude(height=sz[2], center=true)
    rounded_rect_2d([sz[0], sz[1]], r);
}

module plate_outer() {
  rounded_box([L, W, T], corner_r);
}

// Inner window for clipping ribs (keeps them inside the frame)
inner_L = L - 2*frame_w;
inner_W = W - 2*frame_w;

module inner_window_box(h=T) {
  rounded_box([inner_L, inner_W, h], max(0, corner_r - frame_w/2));
}

// Compute cutout size to fit inside inner area with requested gaps
cut_w = (inner_L - (cut_cols-1)*gap_x) / cut_cols;
cut_h = (inner_W - (cut_rows-1)*gap_y) / cut_rows;

module cutout_at(ix, iy) {
  // ix: 0..cut_cols-1, iy: 0..cut_rows-1 (top to bottom)
  x0 = -inner_L/2 + cut_w/2;
  y0 =  inner_W/2 - cut_h/2;

  x = x0 + ix*(cut_w + gap_x);
  y = y0 - iy*(cut_h + gap_y);

  translate([x, y, 0])
    rounded_box([cut_w, cut_h, T + 4*overlap],
                clamp(cut_r, 0, min(cut_w, cut_h)/2 - 1e-6));
}

module cutouts_union() {
  union() {
    for (ix = [0:cut_cols-1])
      for (iy = [0:cut_rows-1])
        cutout_at(ix, iy);
  }
}

module rib_bar(len, h) {
  cube([len, rib_w, h], center=true);
}

module diagonal_ribs() {
  // Long enough to span the inner window; then clipped to inner window so ribs connect to frame.
  rib_len = sqrt(inner_L*inner_L + inner_W*inner_W) + 2*frame_w;

  // Make ribs slightly thicker in Z and slightly offset so they fuse with the plate.
  rib_h = T + z_fuse;
  rib_z = 0; // centered; extra height ensures overlap with plate

  intersection() {
    union() {
      translate([0,0,rib_z]) rotate([0,0, rib_angle_deg]) rib_bar(rib_len, rib_h);
      translate([0,0,rib_z]) rotate([0,0,-rib_angle_deg]) rib_bar(rib_len, rib_h);
    }
    // Clip to inner window (expanded slightly for guaranteed connection)
    rounded_box([inner_L + 2*overlap, inner_W + 2*overlap, rib_h + 2*overlap],
                max(0, corner_r - frame_w/2));
  }
}

module base_panel_with_openings() {
  // Single flat plate with six openings (keeps the "vented panel" look).
  difference() {
    plate_outer();
    cutouts_union();
  }
}

union() {
  // Base vented plate
  base_panel_with_openings();

  // Add diagonal ribs AFTER cutouts so they remain visible and create the stepped/angled transitions.
  // They are clipped to the inner window so they don't overwrite the perimeter frame.
  diagonal_ribs();
}
}
