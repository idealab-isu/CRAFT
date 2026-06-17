// Dimension-calibrated (target: 0.18 x 0.13 x 0.01 mm)
scale([0.920000, 1.260000, 1.666667])
{
// Thin vented/stiffened plate: perimeter frame + 6 rounded-rect cutouts (3x2)
// + TWO DIAGONAL RIBS that remain visible (not cut away) by masking cutouts.
// Target bounding box: 0.20 x 0.10 x very thin. One connected solid.

$fn = 64;

// ---------- Overall size ----------
L = 0.20;          // overall length (X)
W = 0.10;          // overall width  (Y)
T = 0.001;         // very thin thickness (Z)

// ---------- Frame / layout ----------
frame_w = 0.010;   // perimeter frame width

gap_x = 0.008;     // bar between columns
gap_y = 0.008;     // bar between rows

// Openings: rounded rectangles
cutout_w  = 0.045; // opening width  (X)
cutout_h  = 0.030; // opening height (Y)
cutout_r  = 0.006; // corner radius

// Diagonal ribs/webs (make them clearly visible)
rib_w = 0.010;         // rib width
rib_angle_deg = 35;    // diagonal angle

// Small numeric epsilon to avoid coplanar artifacts
eps = 0.0005;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
  rr = min(r, w/2 - 1e-6, h/2 - 1e-6);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - rr), sy*(h/2 - rr)]) circle(r=rr);
  }
}

module rounded_rect_3d(w, h, r, t) {
  linear_extrude(height=t, center=true)
    rounded_rect_2d(w, h, r);
}

module rib_bar(len, w, t) {
  cube([len, w, t], center=true);
}

// ---------- Derived grid positions (3x2) ----------
pitch_x = cutout_w + gap_x;
pitch_y = cutout_h + gap_y;

xpos = [-pitch_x, 0, pitch_x];
ypos = [ pitch_y/2, -pitch_y/2];

// ---------- Main solids ----------
module base_plate() {
  cube([L, W, T], center=true);
}

module perimeter_frame() {
  // Slight overlap in Z to avoid coplanar artifacts with base_plate
  difference() {
    cube([L, W, T + 2*eps], center=true);
    cube([L - 2*frame_w, W - 2*frame_w, T + 6*eps], center=true);
  }
}

module diagonal_ribs() {
  // Keep ribs inside the interior window so they read as interior webs
  interior_L = L - 2*frame_w;
  interior_W = W - 2*frame_w;

  rib_len = sqrt(interior_L*interior_L + interior_W*interior_W) + 4*eps;

  // Clip ribs to interior window so they don't protrude into the outer frame
  intersection() {
    cube([interior_L, interior_W, T + 8*eps], center=true);
    union() {
      rotate([0,0, rib_angle_deg])  rib_bar(rib_len, rib_w, T + 4*eps);
      rotate([0,0,-rib_angle_deg])  rib_bar(rib_len, rib_w, T + 4*eps);
    }
  }
}

module all_cutouts() {
  for (x = xpos)
    for (y = ypos)
      translate([x, y, 0])
        rounded_rect_3d(cutout_w, cutout_h, cutout_r, T + 20*eps);
}

// Mask used to keep ribs from being removed by the cutouts.
// This creates the requested "stepped/angled transitions" where ribs cross openings.
module rib_keepout_mask() {
  // Slightly wider than ribs so the ribs remain clearly visible after subtraction.
  keep_w = rib_w + 2*eps;

  interior_L = L - 2*frame_w;
  interior_W = W - 2*frame_w;
  rib_len = sqrt(interior_L*interior_L + interior_W*interior_W) + 4*eps;

  intersection() {
    cube([interior_L, interior_W, T + 30*eps], center=true);
    union() {
      rotate([0,0, rib_angle_deg])  rib_bar(rib_len, keep_w, T + 24*eps);
      rotate([0,0,-rib_angle_deg])  rib_bar(rib_len, keep_w, T + 24*eps);
    }
  }
}

// ---------- Final (one connected solid) ----------
difference() {
  union() {
    // Base plate guarantees connectivity; frame + ribs add stiffness/webs
    base_plate();
    perimeter_frame();
    diagonal_ribs();
  }

  // Subtract cutouts, but DO NOT subtract where ribs exist (so ribs remain visible across openings)
  difference() {
    all_cutouts();
    rib_keepout_mask();
  }
}
}
