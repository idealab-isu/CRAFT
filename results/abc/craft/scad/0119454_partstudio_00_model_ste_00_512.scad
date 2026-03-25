// Dimension-calibrated (target: 0.10 x 0.06 x 0.05 mm)
scale([1.000006, 0.937512, 0.833353])
{
// U-shaped fork/clevis bracket with tapered end + transverse hex through-hole
// Bounding box target: 0.1 x 0.1 x 0.1 mm (model fits within these limits)
// Elongated along X

$fn = 96;

// -------------------- Overall bounds --------------------
L = 0.1;     // X (elongated)
W = 0.06;    // Y
H = 0.05;    // Z

// -------------------- Fork slot (through Z, open at tapered end) --------------------
slot_L = 0.075;
slot_W = 0.028;
slot_end_offset = 0.005;

// -------------------- End features --------------------
chamfer_L = 0.015;          // tapered/chamfered end length (at x=0)
round_end_R = 0.03;         // rounded end radius (at x=L)

// -------------------- Hex through-hole (axis along Y, near rounded end) --------------------
hex_flat_to_flat = 0.02;
hex_axis_offset_from_round_start = 0.02; // from x = (L - round_end_R)
hex_axis_z = H/2;

// -------------------- Robustness / overlap --------------------
eps = 0.0005;               // tiny numerical epsilon (mm)
over = 0.002;               // overlap for boolean robustness (mm)

// --- Helpers ---
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Convert flat-to-flat to circumradius for a regular hex
function hex_R_from_F(F) = F / sqrt(3);

// Regular hex polygon centered at origin
module hex2d(F) {
  R = hex_R_from_F(F);
  polygon(points=[ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// Main body with rounded end (union of prism + cylindrical cap)
// Ensures overall X extent is exactly L (cap centered at x = L - round_end_R)
module body_with_round_end() {
  union() {
    // Main prism: x in [0, L-round_end_R]
    cube([L - round_end_R, W, H], center=false);

    // Rounded end cap: cylinder axis along Y, centered at x = L - round_end_R
    // Extends in X from (L - 2*round_end_R) to L
    translate([L - round_end_R, W/2, H/2])
      rotate([90, 0, 0])
        cylinder(r=round_end_R, h=W + 2*over, center=true);
  }
}

// CLEAR chamfer/taper at x=0: remove a wedge that slopes in Z from full height to 0
// Implemented as a non-degenerate polyhedron (no duplicated points).
module tapered_end_cut() {
  polyhedron(
    points=[
      // x=0 plane (collapsed to z=0 edge)
      [0,         0, 0],   // 0
      [0,         W, 0],   // 1

      // x=chamfer_L plane (full height)
      [chamfer_L, 0, 0],   // 2
      [chamfer_L, W, 0],   // 3
      [chamfer_L, 0, H],   // 4
      [chamfer_L, W, H]    // 5
    ],
    faces=[
      // bottom
      [0,2,3,1],
      // sloped top
      [0,1,5,4],
      // y=0 side
      [0,4,2],
      // y=W side
      [1,3,5],
      // x=chamfer_L side
      [2,4,5,3],
      // x=0 side (degenerate area but acceptable boundary)
      [0,1,3,2]
    ]
  );
}

// Through-slot: remove rectangular prism through Z, open at x=0 (starts at slot_end_offset)
module fork_slot_cut() {
  slot_x0 = clamp(slot_end_offset, 0, L);
  slot_x1 = clamp(slot_end_offset + slot_L, 0, L);
  slot_len = max(eps, slot_x1 - slot_x0);

  translate([slot_x0 - over, (W - slot_W)/2, -over])
    cube([slot_len + 2*over, slot_W, H + 2*over], center=false);
}

// Transverse hex through-hole (axis along Y), near rounded end
// FIX: ensure it is a TRUE through-hole across full width by extruding along Y
// and center it in Z so it is visible in orthographic views.
module hex_hole_cut() {
  // Desired center near rounded end
  x_center_raw = (L - round_end_R) + hex_axis_offset_from_round_start;

  // Keep the hex fully inside X bounds (avoid clipping at x=0 or x=L)
  Rhex = hex_R_from_F(hex_flat_to_flat);
  x_center = clamp(x_center_raw, Rhex + eps, L - Rhex - eps);

  // Through-hole along Y: extrude height >= W with overlap
  translate([x_center, W/2, clamp(hex_axis_z, Rhex + eps, H - Rhex - eps)])
    rotate([90, 0, 0])  // make extrude axis align with Y
      linear_extrude(height=W + 2*over, center=true, convexity=10)
        hex2d(hex_flat_to_flat);
}

// Final model (single connected solid)
difference() {
  body_with_round_end();

  // Cuts
  fork_slot_cut();
  hex_hole_cut();

  // Chamfer cut from the body to make the tapered end clearly visible
  // Extend in Y/Z via overlap to ensure clean subtraction.
  translate([0, -over, -over])
    scale([1, (W + 2*over)/W, (H + 2*over)/H])
      tapered_end_cut();
}
}
