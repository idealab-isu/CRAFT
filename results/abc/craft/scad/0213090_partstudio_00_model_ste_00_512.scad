// Dimension-calibrated (target: 0.15 x 0.13 x 0.08 mm)
scale([0.600822, 0.760185, 1.270020])
{
// Compact mounting bracket with rounded-rectangle base and elbowed arm
// Bounding box target: 0.2 x 0.1 x 0.1 mm (X x Y x Z)

$fn = 64;

// ---- Target bounding box ----
bbox_L = 0.2;
bbox_W = 0.1;
bbox_H = 0.1;

// ---- Base ----
base_L = 0.10;
base_W = bbox_W;
base_H = bbox_H;
base_corner_r = 0.02;

// ---- Arm (plan-view elbow) ----
arm_thk = 0.04;                 // thickness in Z (sits on top of base)
arm_w = 0.028;                  // main arm width in Y
arm_neck_w = 0.018;             // narrow neck width in Y
arm_neck_L = 0.018;             // neck length in X
arm_elbow_offset_W = 0.028;     // Y offset of the arm after elbow
arm_end_L = 0.034;              // obround end length in X
arm_end_W = 0.040;              // obround end width in Y

// Derived to hit bbox_L exactly
arm_reach_L = bbox_L - base_L/2; // from base center to arm tip in +X

// ---- Neck side bosses/steps ----
boss_L = 0.010;
boss_W = 0.008;
boss_H = 0.020;

// ---- Cuts ----
cavity_L = 0.030;
cavity_W = 0.050;
cavity_H = 0.040;

hole_r = 0.006;
hole_edge_margin = 0.020;

step_depth = 0.010;
step_band_W = 0.020;

overlap = 0.001;

// ----------------- Helpers -----------------
module rounded_rect_2d(L, W, r) {
  r2 = min(r, min(L, W)/2 - 1e-6);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - r2), sy*(W/2 - r2)]) circle(r=r2);
  }
}

module obround_2d(L, W) {
  // L >= W recommended
  L2 = max(L, W);
  hull() {
    translate([-(L2/2 - W/2), 0]) circle(r=W/2);
    translate([ (L2/2 - W/2), 0]) circle(r=W/2);
  }
}

// ----------------- Base -----------------
module base_block() {
  linear_extrude(height=base_H, center=true)
    rounded_rect_2d(base_L, base_W, base_corner_r);
}

// ----------------- Arm (single connected solid) -----------------
module arm_solid() {
  // Place arm on top surface of base
  zc = base_H/2 - arm_thk/2;

  // Key X positions (all formula-based)
  x0 = base_L/2 - overlap;                 // start slightly inside base for guaranteed connection
  x1 = x0 + arm_neck_L;                    // end of neck
  x_tip = base_L/2 + arm_reach_L;          // absolute tip in +X (bbox_L/2)
  x_end_center = x_tip - arm_end_L/2;      // center of obround end
  x_end_start = x_tip - arm_end_L;         // start of obround end
  x_mid_end = x_end_start - overlap;       // end of mid segment (overlap into end)

  // Elbow corner center (plan view)
  // Use a quarter-round elbow with radius = arm_w/2
  r_elbow = arm_w/2;
  x_corner = x1 + r_elbow;
  y_corner = r_elbow;

  // Ensure there is some straight length after elbow before the end
  // Mid segment starts after elbow and runs to just before obround end
  x_mid_start = x_corner;
  y_mid = arm_elbow_offset_W;

  union() {
    // Neck (narrow)
    translate([(x0 + x1)/2, 0, zc])
      cube([x1 - x0 + overlap, arm_neck_w, arm_thk], center=true);

    // Small side bosses around neck region (on top of base)
    translate([x0 + boss_L/2,  (arm_neck_w/2 + boss_W/2 - overlap), base_H/2 - boss_H/2])
      cube([boss_L, boss_W, boss_H], center=true);
    translate([x0 + boss_L/2, -(arm_neck_w/2 + boss_W/2 - overlap), base_H/2 - boss_H/2])
      cube([boss_L, boss_W, boss_H], center=true);

    // Transition from neck width to arm width (short blend block)
    blend_L = max(arm_w, 0.012);
    translate([x1 + blend_L/2 - overlap, 0, zc])
      cube([blend_L, arm_w, arm_thk], center=true);

    // Elbow: quarter-ring sector (curved in plan view)
    // Center at (x_corner, y_corner), sweeping from +X to +Y
    translate([x_corner, y_corner, zc])
      linear_extrude(height=arm_thk, center=true)
        difference() {
          intersection() {
            circle(r=arm_w);
            square([arm_w, arm_w], center=false); // first quadrant
          }
          intersection() {
            circle(r=arm_w - arm_w); // placeholder to keep structure valid if arm_w changes
            square([arm_w, arm_w], center=false);
          }
        }

    // Proper elbow as a thick quarter-annulus using offset on a quarter-arc path
    // (Implemented via hull of small circles along the arc for robustness)
    translate([0,0,zc])
      linear_extrude(height=arm_thk, center=true)
        hull() {
          for (a = [0:10:90]) {
            translate([x_corner + r_elbow*cos(a), y_corner + r_elbow*sin(a)])
              circle(r=arm_w/2);
          }
        }

    // Straight segment after elbow (at Y offset)
    mid_L = max(0.0, x_mid_end - x_mid_start);
    if (mid_L > 0)
      translate([x_mid_start + mid_L/2, y_mid, zc])
        cube([mid_L + overlap, arm_w, arm_thk], center=true);

    // Obround terminal end (smooth, not faceted)
    translate([x_end_center, y_mid, zc])
      linear_extrude(height=arm_thk, center=true)
        obround_2d(arm_end_L, arm_end_W);
  }
}

// ----------------- Cuts -----------------
module base_relief_cavity() {
  translate([-base_L/2 + base_corner_r + cavity_L/2, 0, -base_H/2 + cavity_H/2 + overlap])
    cube([cavity_L, cavity_W, cavity_H], center=true);
}

module mounting_holes() {
  // Two holes along X, centered in Y
  translate([-base_L/2 + hole_edge_margin, 0, 0])
    cylinder(r=hole_r, h=base_H + 4*overlap, center=true);
  translate([ base_L/2 - hole_edge_margin, 0, 0])
    cylinder(r=hole_r, h=base_H + 4*overlap, center=true);
}

module surface_step_band_cut() {
  translate([0, base_W/2 - step_band_W/2 - overlap, base_H/2 - step_depth/2])
    cube([base_L - 2*base_corner_r, step_band_W, step_depth + 2*overlap], center=true);
}

// ----------------- Assembly -----------------
module bracket() {
  difference() {
    union() {
      base_block();
      arm_solid();
    }
    base_relief_cavity();
    mounting_holes();
    surface_step_band_cut();
  }
}

bracket();
}
