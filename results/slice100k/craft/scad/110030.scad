// Dimension-calibrated (target: 11.00 x 18.92 x 8.76 mm)
scale([1.000211, 0.999636, 1.255444])
{
// T-shaped mechanical fastener/clip (single connected solid)
// Bounding box target: 11.0 x 18.9 x 8.8 mm  (X x Y x Z)

$fn = 96;

// -------------------- Parameters (mm) --------------------
bbox_X = 18.92;
bbox_Y = 11.00;
bbox_Z = 8.76;

// Main shank (X axis)
shank_L = bbox_X;
shank_D = 4.2;

// Slight flare at +X end
flare_L = 2.2;
flare_D = 5.0;

// Transverse body (Y axis)
cross_D = 5.2;
cross_L_total = bbox_Y;

// Fork at -Y end of transverse body (split two-prong)
fork_L = 4.2;                 // length along Y from end inward
fork_gap = 1.2;               // gap between prongs (along X)
fork_prong_thk = bbox_Z;      // prongs span full Z thickness
fork_tip_taper_L = 1.2;       // lead-in taper length along Y

// Boss at intersection (Z axis)
boss_D = 6.6;
boss_thk = 1.6;

// Asymmetric side tab/plate (projects to +Z side, wedge-like)
tab_L = 5.8;                  // along X
tab_W = 4.6;                  // along Y
tab_thk = 1.2;                // along Z
tab_wedge_drop = 0.8;         // wedge slope in Y profile

// Connectivity / robustness
overlap = 0.25;               // small overlap to ensure manifold unions

// -------------------- Helpers --------------------
module bbox_clip() {
  cube([bbox_X, bbox_Y, bbox_Z], center=true);
}

module cyl_x(h, d) { rotate([0,90,0]) cylinder(h=h, r=d/2, center=true); }
module cyl_y(h, d) { rotate([90,0,0]) cylinder(h=h, r=d/2, center=true); }
module cyl_z(h, d) { cylinder(h=h, r=d/2, center=true); }

// -------------------- Main geometry --------------------
module shank() {
  union() {
    // main shank
    cyl_x(shank_L, shank_D);

    // slightly flared end at +X
    translate([shank_L/2 - flare_L/2 + overlap, 0, 0])
      rotate([0,90,0])
        cylinder(h=flare_L + 2*overlap, r1=flare_D/2, r2=shank_D/2, center=true);
  }
}

module transverse_body() {
  // centered at origin, along Y
  cyl_y(cross_L_total, cross_D);
}

module boss() {
  // circular boss at intersection, along Z
  cyl_z(boss_thk, boss_D);
}

module tab_wedge() {
  // Wedge-like plate: extrude in Z, profile in X-Y
  // Asymmetric: placed to +Z side and +Y side slightly.
  linear_extrude(height=tab_thk, center=true)
    polygon(points=[
      [0, 0],
      [tab_L, 0],
      [tab_L, tab_W - tab_wedge_drop],
      [0, tab_W]
    ]);
}

module tab_positioned() {
  // Place tab so it projects to one side (asymmetric head):
  // - sits on +Z side of transverse body
  // - offset slightly toward +Y to look like a wedge/plate on one side
  translate([
    0,                                  // centered in X at intersection
    cross_D/2 - overlap,                // attached to +Y side of cross cylinder
    bbox_Z/2 - tab_thk/2 + overlap       // attached to +Z side (asymmetric)
  ])
    tab_wedge();
}

module fork_cut_gap() {
  // Cut a slot at the -Y end to create two prongs.
  // Slot runs along Y for fork_L, centered in X, full Z.
  translate([0, -cross_L_total/2 + fork_L/2 - overlap, 0])
    cube([fork_gap, fork_L + 2*overlap, fork_prong_thk + 2*overlap], center=true);
}

module fork_tip_taper_cut() {
  // Lead-in taper at the very end (-Y) to suggest snap-in fork tips.
  // Use a wedge cut that opens the gap slightly at the end.
  // Implemented as a hull between two thin rectangles to form a taper.
  y_end = -cross_L_total/2;
  y_in  = y_end + fork_tip_taper_L;

  hull() {
    translate([0, y_end + overlap, 0])
      cube([fork_gap + 1.6, 0.2, fork_prong_thk + 2*overlap], center=true);
    translate([0, y_in, 0])
      cube([fork_gap, 0.2, fork_prong_thk + 2*overlap], center=true);
  }
}

module cross_with_fork() {
  // Start from solid transverse cylinder, then subtract fork slot and taper.
  difference() {
    transverse_body();
    fork_cut_gap();
    fork_tip_taper_cut();
  }
}

module model_solid() {
  union() {
    shank();
    cross_with_fork();
    boss();
    tab_positioned();
  }
}

// -------------------- Final (clipped to exact bbox) --------------------
intersection() {
  model_solid();
  bbox_clip();
}
}
