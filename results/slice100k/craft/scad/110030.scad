// Dimension-calibrated (target: 11.00 x 18.92 x 8.76 mm)
scale([0.904625, 0.939897, 0.559609])
{
// T-shaped mechanical fastener/clip (single connected solid)
// Fixes:
// - Adds a clearly connected asymmetric wedge-like side tab at the intersection
// - Ensures NO detached bodies (tab is attached with overlap and built from a single hull)
// - Adds a slight flare at the free end of the shank
// - Recalculates all translate() placements so parts touch/overlap (1–2mm)
// - Keeps overall bbox intent ~ 11.0 x 18.9 x 8.8 mm and elongated along shank axis

$fn = 64;

// ---------- Parameters (mm) ----------
bbox_L = 18.92; // overall length along shank axis (X)
bbox_W = 11.0;  // overall width across transverse head (Y)
bbox_H = 8.76;  // overall height (Z)

shank_len = bbox_L;
shank_d   = 4.2;

flare_len = 2.2;
flare_d   = 5.0;

head_d         = 6.6;     // transverse cylinder diameter (Z extent)
head_len_total = bbox_W;  // transverse cylinder length (Y)

fork_len       = 4.4;     // fork region length at +Y end
fork_gap       = 1.2;     // gap between prongs (X direction)
fork_open_z    = 0.55;    // open the slot upward a bit to read as a fork
fork_tip_round = 0.7;     // rounded lead-in at tip

boss_d   = 7.6;
boss_thk = 1.6;

tab_len        = 5.2;  // along Y
tab_thk        = 1.6;  // along X (projection)
tab_h          = 3.2;  // along Z
tab_wedge_drop = 1.2;  // wedge taper amount (Z)

overlap = 1.2;         // ensure solid connections (1–2mm)
fillet_r = 0.35;

// ---------- Derived placement ----------
// Put the head/boss near the -X end of the shank, but keep overlap into shank.
x_int = -(shank_len/2 - boss_thk/2 - overlap);

// ---------- Base shapes ----------
module shank_cylinder() {
  rotate([0,90,0])
    cylinder(h=shank_len, r=shank_d/2, center=true);
}

module shank_flared_end() {
  // Slight flare at +X end of shank; overlaps into shank so it is one solid.
  rotate([0,90,0])
    translate([shank_len/2 - flare_len/2, 0, 0])
      cylinder(h=flare_len + overlap, r1=shank_d/2, r2=flare_d/2, center=true);
}

module transverse_body_cylinder() {
  // Transverse cylinder along Y, centered at x_int
  translate([x_int, 0, 0])
    rotate([90,0,0])
      cylinder(h=head_len_total, r=head_d/2, center=true);
}

module intersection_boss() {
  // Boss disk around intersection, coaxial with shank (X)
  translate([x_int, 0, 0])
    rotate([0,90,0])
      cylinder(h=boss_thk + overlap, r=boss_d/2, center=true);
}

// ---------- Side tab (connected, wedge-like) ----------
module side_tab_wedge() {
  // Flat wedge-like rectangular tab projecting to +X side (asymmetric).
  // It is explicitly overlapped into the head/boss region so it cannot detach.

  // Anchor the tab so its inner face penetrates the head by ~overlap.
  // Head outer surface in +X is at x_int + head_d/2.
  // Place tab center so inner face is at (head surface - overlap).
  x_center = (x_int + head_d/2 - overlap) + tab_thk/2;

  // Place near +Y side of head (as in reference), but still on the head.
  y_center = head_len_total/2 - tab_len/2;

  // Keep within bbox_H; slightly above centerline for the "plate" look.
  z_center = min((bbox_H/2 - tab_h/2), head_d/2 - tab_h/2) + tab_h/2 - 0.2;

  // Wedge: thicker/taller at the base, tapering toward the outer/top edge.
  hull() {
    // Base block (flat plate)
    translate([x_center, y_center, z_center - tab_wedge_drop/2])
      cube([tab_thk, tab_len, tab_h], center=true);

    // Tapered top/outer cap (smaller)
    translate([x_center + tab_thk*0.15, y_center, z_center + tab_h/2 - tab_wedge_drop])
      cube([max(0.8, tab_thk*0.55), tab_len*0.92, 0.8], center=true);
  }
}

// ---------- Fork (distinct two-prong split) ----------
module fork_slot_cutter() {
  // Cut a slot at +Y end of transverse cylinder to create two prongs.
  x0 = x_int;
  y0 = head_len_total/2 - fork_len/2;

  // Main slot (splits prongs)
  translate([x0, y0, 0])
    cube([fork_gap, fork_len + 2*overlap, head_d + 2*overlap], center=true);

  // Open the slot upward slightly so it reads as a fork
  translate([x0, y0, head_d/2 - fork_open_z/2])
    cube([fork_gap + 0.2, fork_len + 2*overlap, fork_open_z + 2*overlap], center=true);

  // Rounded lead-in at the fork tip (+Y end)
  translate([x0, head_len_total/2 - fork_tip_round/2, 0])
    rotate([90,0,0])
      cylinder(h=fork_tip_round + 2*overlap, r=fork_gap/2 + 0.35, center=true);
}

module fork_outer_relief_cutter() {
  // Outer relief scallops to visually separate prongs
  x0 = x_int;
  y_tip = head_len_total/2 - fork_len*0.55;
  r_rel = 1.0;

  for (sx = [-1, 1]) {
    translate([x0 + sx*(fork_gap/2 + r_rel*0.65), y_tip, 0])
      rotate([90,0,0])
        cylinder(h=fork_len + 2*overlap, r=r_rel, center=true);
  }
}

module transverse_body_with_fork() {
  difference() {
    transverse_body_cylinder();
    fork_slot_cutter();
    fork_outer_relief_cutter();
  }
}

// ---------- Assembly ----------
module main_union() {
  union() {
    shank_cylinder();
    shank_flared_end();
    transverse_body_with_fork();
    intersection_boss();
    side_tab_wedge();
  }
}

// ---------- Final (small fillet via Minkowski) ----------
minkowski() {
  main_union();
  sphere(r=fillet_r);
}
}
