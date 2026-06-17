// Symmetric elongated bracket/strap with central thick block + square through-window,
// two wide arms, stepped junctions, and ribs on ONE face.
// Bounding box target: W x L x H = 10.92 x 43.93 x 10.64 (Y x X x Z)

$fn = 48;

// Overall target envelope
L = 43.93;                 // overall length (X)
W = 10.92;                 // overall width  (Y)
H = 10.64;                 // overall height (Z)

// Core proportions
center_L = 12.0;           // central block length (X)
center_W = W;              // central block width  (Y)
center_H = H;              // central block height (Z)

arm_L_each = (L - center_L)/2;  // each arm length (X)
arm_W = W;                      // arm width (Y)
arm_H = 6.5;                    // arm thickness (Z)

junction_step_L = 2.0;          // step length into arm (X)
junction_step_H = 2.0;          // extra height above arm at junction (Z)

// Window (square through-window in central block)
window_size = 5.0;              // square size (Y and Z)

// Ribs (on one face)
rib_count = 4;
rib_H = 1.0;                    // rib height (Z)
rib_W = 1.2;                    // rib width (Y)
rib_margin_side = 1.0;          // side margin in Y
rib_face = 1;                   // 1 = ribs on +Z face, 0 = ribs on -Z face

// Connectivity + edge softening
overlap = 1.2;                  // 1–2mm overlap for robust unions
chamfer = 0.6;                  // small roundover via minkowski

module roundover_sphere() { sphere(r=chamfer/2); }

// --- Base solids (all centered at origin, X is length axis) ---

module central_block() {
  cube([center_L, center_W, center_H], center=true);
}

module arm(sign=1) { // sign = -1 left, +1 right
  // Inner face of arm overlaps into central block by 'overlap'
  x = sign * (center_L/2 + arm_L_each/2 - overlap);
  // Arms sit flush to bottom of central block
  z = -center_H/2 + arm_H/2;
  translate([x, 0, z])
    cube([arm_L_each, arm_W, arm_H], center=true);
}

module junction_step(sign=1) {
  // Step sits on top of the arm at the junction, overlapping into central block
  x = sign * (center_L/2 + junction_step_L/2 - overlap);
  z = -center_H/2 + (arm_H + junction_step_H)/2;
  translate([x, 0, z])
    cube([junction_step_L, arm_W, arm_H + junction_step_H], center=true);
}

// Square through-window: square in Y-Z, cut through Z (so it is visible in top/bottom views)
module square_through_window() {
  // Cut through full height (Z) with margin for minkowski rounding.
  // Confine in X to central block region.
  cube([window_size, window_size, center_H + 2*(chamfer + 1.0)], center=true);
}

// Ribs: long along X, placed on one face (top or bottom)
module rib_at_y(ypos) {
  zpos = (rib_face == 1) ? (H/2 - rib_H/2) : (-H/2 + rib_H/2);
  translate([0, ypos, zpos])
    cube([L - 2*overlap, rib_W, rib_H], center=true);
}

module ribs_union() {
  usable = W - 2*rib_margin_side - rib_W;
  step = (rib_count <= 1) ? 0 : usable/(rib_count - 1);
  y0 = -usable/2;

  for (i = [0:rib_count-1])
    rib_at_y(y0 + i*step);
}

// Main shape (single connected solid)
module main_solid() {
  union() {
    central_block();
    arm(-1);
    arm(1);
    junction_step(-1);
    junction_step(1);
    ribs_union();
  }
}

// Cut window AFTER union so it is clearly a through-window
module with_window() {
  difference() {
    main_solid();
    square_through_window();
  }
}

// Final: small roundovers (window remains through due to oversize cut)
minkowski() {
  with_window();
  roundover_sphere();
}