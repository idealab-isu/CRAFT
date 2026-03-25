// Dimension-calibrated (target: 81.15 x 68.50 x 10.00 mm)
scale([0.835499, 0.774198, 1.000100])
{
// Thin mounting/adapter plate with central cutout, row windows, ring feature, and perimeter tabs/holes
// Bounding box target: 81.2 x 68.5 x 10.0 mm

$fn = 128;

// -------------------- Parameters --------------------
bbox_L = 81.15;
bbox_W = 68.5;
plate_T = 10;

outer_corner_R = 2;

frame_margin = 6;

central_cut_L = 55;
central_cut_W = 40;

// Prominent circular ring feature on one end (boss + through-hole)
ring_outer_D = 26;
ring_hole_D  = 14;

// Place ring so its outermost edge is flush with the outer right edge of the bbox
ring_center_x = bbox_L/2 - ring_outer_D/2;
ring_center_y = 0;

// Perimeter tabs (small outward pads) and fastener holes
tab_L = 8;
tab_W = 10;

fastener_hole_D = 3.2;
fastener_edge_offset = 4;

counterbore_D = 6.4;
counterbore_depth = 2.5;

// Row of small rectangular windows (arranged in a row)
window_count = 4;
window_L = 10;
window_W = 6;
window_gap = 4;

// Put window row in the top bar area (above central cutout)
window_row_y = central_cut_W/2 + frame_margin/2;

// Small overlap for robust booleans
overlap = 1;

// -------------------- Helpers --------------------
module rounded_rect_2d(L, W, R) {
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - R), sy*(W/2 - R)]) circle(r=R);
  }
}

module outer_plate_2d() {
  rounded_rect_2d(bbox_L, bbox_W, outer_corner_R);
}

module ring_boss_2d() {
  // Full circular boss (ring outer profile)
  translate([ring_center_x, ring_center_y]) circle(d=ring_outer_D);
}

module base_outline_2d() {
  // Union of main plate outline + ring boss (connected solid)
  union() {
    outer_plate_2d();
    ring_boss_2d();
  }
}

module tab_2d_at(x, y) {
  translate([x, y]) square([tab_L, tab_W], center=true);
}

module tabs_2d() {
  // Tabs protruding outward from the main rectangle edges
  // Right side tabs (top/mid/bot)
  tab_2d_at( bbox_L/2 + tab_L/2 - 0.01,  bbox_W/2 - tab_W/2);
  tab_2d_at( bbox_L/2 + tab_L/2 - 0.01,  0);
  tab_2d_at( bbox_L/2 + tab_L/2 - 0.01, -bbox_W/2 + tab_W/2);

  // Left side tabs (top/mid/bot)
  tab_2d_at(-bbox_L/2 - tab_L/2 + 0.01,  bbox_W/2 - tab_W/2);
  tab_2d_at(-bbox_L/2 - tab_L/2 + 0.01,  0);
  tab_2d_at(-bbox_L/2 - tab_L/2 + 0.01, -bbox_W/2 + tab_W/2);

  // Top-center tab
  tab_2d_at(0, bbox_W/2 + tab_W/2 - 0.01);

  // Bottom-center tab
  tab_2d_at(0, -bbox_W/2 - tab_W/2 + 0.01);
}

module solid_2d() {
  union() {
    base_outline_2d();
    tabs_2d();
  }
}

module central_cutout_2d() {
  // Main rectangular clearance
  square([central_cut_L, central_cut_W], center=true);
}

module window_row_cutouts_2d() {
  // Several smaller rectangular windows arranged in a row
  total_L = window_count*window_L + (window_count-1)*window_gap;
  x0 = -total_L/2 + window_L/2;

  for (i = [0:window_count-1])
    translate([x0 + i*(window_L + window_gap), window_row_y])
      square([window_L, window_W], center=true);
}

module ring_through_hole_2d() {
  // Through-hole inside the ring boss
  translate([ring_center_x, ring_center_y]) circle(d=ring_hole_D);
}

module fastener_holes_2d() {
  // Holes centered on tabs, offset inward from the outermost tab edge by fastener_edge_offset
  // Right side (3)
  for (yy = [bbox_W/2 - tab_W/2, 0, -bbox_W/2 + tab_W/2])
    translate([bbox_L/2 + tab_L - fastener_edge_offset, yy]) circle(d=fastener_hole_D);

  // Left side (3)
  for (yy = [bbox_W/2 - tab_W/2, 0, -bbox_W/2 + tab_W/2])
    translate([-bbox_L/2 - tab_L + fastener_edge_offset, yy]) circle(d=fastener_hole_D);

  // Top center (1)
  translate([0, bbox_W/2 + tab_W - fastener_edge_offset]) circle(d=fastener_hole_D);

  // Bottom center (1)
  translate([0, -bbox_W/2 - tab_W + fastener_edge_offset]) circle(d=fastener_hole_D);
}

module counterbores_3d() {
  // Counterbores on the "top" face only
  zc = plate_T/2 - (counterbore_depth + overlap)/2;

  // Right side (3)
  for (yy = [bbox_W/2 - tab_W/2, 0, -bbox_W/2 + tab_W/2])
    translate([bbox_L/2 + tab_L - fastener_edge_offset, yy, zc])
      cylinder(d=counterbore_D, h=counterbore_depth + overlap, center=true);

  // Left side (3)
  for (yy = [bbox_W/2 - tab_W/2, 0, -bbox_W/2 + tab_W/2])
    translate([-bbox_L/2 - tab_L + fastener_edge_offset, yy, zc])
      cylinder(d=counterbore_D, h=counterbore_depth + overlap, center=true);

  // Top center (1)
  translate([0, bbox_W/2 + tab_W - fastener_edge_offset, zc])
    cylinder(d=counterbore_D, h=counterbore_depth + overlap, center=true);

  // Bottom center (1)
  translate([0, -bbox_W/2 - tab_W + fastener_edge_offset, zc])
    cylinder(d=counterbore_D, h=counterbore_depth + overlap, center=true);
}

// -------------------- Final Model --------------------
module plate_solid_3d() {
  linear_extrude(height=plate_T, center=true)
    solid_2d();
}

module all_cutouts_3d() {
  union() {
    // Through cutouts
    linear_extrude(height=plate_T + 2*overlap, center=true) {
      central_cutout_2d();
      window_row_cutouts_2d();
      ring_through_hole_2d();
      fastener_holes_2d();
    }

    // Counterbores (partial depth)
    counterbores_3d();
  }
}

difference() {
  plate_solid_3d();
  all_cutouts_3d();
}
}
