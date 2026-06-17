$fn = 128;

// Target bounding box (overall extents)
bb_L = 81.2;
bb_W = 68.5;
T    = 10.0;

// Tabs / outline
tab_depth = 6.0;      // outward in Y for top/bottom tabs
tab_W     = 12.0;     // width of corner tabs along X
side_tab_depth = 6.0; // outward in X for mid side tabs
side_tab_W     = 14.0;

// Base width reduced so tabs define overall bb_W
base_W = bb_W - 2*tab_depth;

// Central opening (large)
cutout_L = 55.0;
cutout_W = 40.0;

// Several smaller rectangular window cutouts arranged in a row (fully enclosed)
n_windows = 4;
win_L = 9.0;
win_W = 6.5;
win_gap = 4.0;

// Place the window row in solid material between the big cutout and the top edge
win_row_y = min(base_W/2 - win_W/2 - 2.0, cutout_W/2 + win_W/2 + 3.0);

// Prominent circular through-hole ring feature on left end (adds material + through-hole)
ring_outer_D = 26.0;
ring_inner_D = 14.0;

// Ensure ring is a DISTINCT end feature: place its center slightly OUTSIDE the base,
// but still within overall bb_L, and overlap into the base by overlap_mm.
overlap_mm = 1.5;

// Base spans X: [-bb_L/2, +bb_L/2]
// Ring outermost left should be at -bb_L/2, so center_x = -bb_L/2 + ring_outer_D/2
// Then shift LEFT by overlap_mm so it protrudes beyond base, and overlaps base by overlap_mm.
ring_center_x = (-bb_L/2 + ring_outer_D/2) - overlap_mm;
ring_center   = [ring_center_x, 0];

// Fasteners
fastener_D = 3.2;
fastener_edge_offset = 5.0;

eps = 0.2;

module rect2D(w, h) { square([w, h], center=true); }

module plate_outline_2D() {
  union() {
    // Main base rectangle (narrower in Y so tabs can extend to bb_W)
    rect2D(bb_L, base_W);

    // Corner tabs (top/bottom) - flush to base edges (touching, no gaps)
    translate([-bb_L/2 + tab_W/2,  base_W/2 + tab_depth/2]) rect2D(tab_W, tab_depth);
    translate([ bb_L/2 - tab_W/2,  base_W/2 + tab_depth/2]) rect2D(tab_W, tab_depth);
    translate([-bb_L/2 + tab_W/2, -base_W/2 - tab_depth/2]) rect2D(tab_W, tab_depth);
    translate([ bb_L/2 - tab_W/2, -base_W/2 - tab_depth/2]) rect2D(tab_W, tab_depth);

    // Mid side tabs (left/right) - flush to base edges (touching, no gaps)
    translate([-bb_L/2 - side_tab_depth/2, 0]) rect2D(side_tab_depth, side_tab_W);
    translate([ bb_L/2 + side_tab_depth/2, 0]) rect2D(side_tab_depth, side_tab_W);

    // Prominent ring boss on left end (distinct annular feature)
    // Positioned to protrude beyond the base and overlap into it by overlap_mm.
    translate(ring_center) circle(d=ring_outer_D);
  }
}

module cutouts_2D() {
  union() {
    // Central rectangular cutout
    rect2D(cutout_L, cutout_W);

    // Row of smaller rectangular WINDOW cutouts (fully enclosed, not edge notches)
    for (i = [0:n_windows-1]) {
      x0 = -(n_windows-1)*(win_L+win_gap)/2 + i*(win_L+win_gap);
      translate([x0, win_row_y]) rect2D(win_L, win_W);
    }

    // Ring through-hole (concentric with boss)
    translate(ring_center) circle(d=ring_inner_D);

    // Fastener through-holes on outward tabs around perimeter
    // Corner tab holes (near outer corners)
    translate([-bb_L/2 + fastener_edge_offset,  bb_W/2 - fastener_edge_offset]) circle(d=fastener_D);
    translate([ bb_L/2 - fastener_edge_offset,  bb_W/2 - fastener_edge_offset]) circle(d=fastener_D);
    translate([-bb_L/2 + fastener_edge_offset, -bb_W/2 + fastener_edge_offset]) circle(d=fastener_D);
    translate([ bb_L/2 - fastener_edge_offset, -bb_W/2 + fastener_edge_offset]) circle(d=fastener_D);

    // Mid-side tab holes (left/right) - centered on the side tabs
    // Left tab spans X: [-bb_L/2 - side_tab_depth, -bb_L/2]
    translate([-bb_L/2 - side_tab_depth + fastener_edge_offset, 0]) circle(d=fastener_D);
    // Right tab spans X: [ bb_L/2, bb_L/2 + side_tab_depth]
    translate([ bb_L/2 + side_tab_depth - fastener_edge_offset, 0]) circle(d=fastener_D);

    // Top/bottom mid holes (on the top/bottom edges)
    translate([0,  bb_W/2 - fastener_edge_offset]) circle(d=fastener_D);
    translate([0, -bb_W/2 + fastener_edge_offset]) circle(d=fastener_D);
  }
}

// Final model (single connected solid)
difference() {
  linear_extrude(height=T, center=true, convexity=10)
    plate_outline_2D();

  linear_extrude(height=T + 2*eps, center=true, convexity=10)
    cutouts_2D();
}