// Compact housing with side latch boss, opposite recessed notch, and integral neck+tab with through-hole
// Target bounding box: 1.4 x 1.0 x 2.6 mm  (X x Y x Z)

$fn = 48;

// --- Target overall bbox ---
bbox_X = 1.40;
bbox_Y = 1.00;
bbox_Z = 2.60;

// --- Main body (rounded-rect block) ---
body_X = 1.40;
body_Y = 1.00;
body_Z = 1.85;
body_r = 0.12;

// --- Neck + tab (integral handle) ---
neck_Z = 0.25;
neck_X = 0.55;
neck_Y = 0.55;

tab_Z  = bbox_Z - body_Z - neck_Z;   // ensures total Z matches bbox_Z
tab_X  = 0.90;
tab_Y  = 0.80;
tab_r  = 0.10;

hole_d = 0.28;

// --- Side latch boss (protrusion) ---
latch_X = 0.22;
latch_Y = 0.18;
latch_Z = 0.35;
latch_r = 0.04;
latch_z_from_body_bottom = 0.55; // position along body height (Z)

// --- Opposite face recessed notch (relief) ---
notch_X = 0.40;
notch_depth = 0.12;  // into face
notch_Z = 0.30;
notch_r = 0.05;
notch_z_from_body_bottom = 0.55; // aligned opposite latch

overlap = 0.02;

// Rounded box helper (centered)
module rbox(sz=[1,1,1], r=0.1) {
  r2 = min(r, sz[0]/2 - 1e-6, sz[1]/2 - 1e-6, sz[2]/2 - 1e-6);
  minkowski() {
    cube([sz[0]-2*r2, sz[1]-2*r2, sz[2]-2*r2], center=true);
    sphere(r=r2);
  }
}

module body() {
  rbox([body_X, body_Y, body_Z], body_r);
}

module latch_boss() {
  // Protrude from +X face; centered in Y; positioned along Z
  translate([
    body_X/2 + latch_X/2 - overlap,
    0,
    -body_Z/2 + latch_z_from_body_bottom
  ])
    rbox([latch_X, latch_Y, latch_Z], latch_r);
}

module opposite_notch_cut() {
  // Recess into -X face; centered in Y; positioned along Z
  translate([
    -body_X/2 + notch_depth/2 + overlap,
    0,
    -body_Z/2 + notch_z_from_body_bottom
  ])
    rbox([notch_depth + 2*overlap, notch_X, notch_Z], notch_r);
}

module neck() {
  // Connects on +Z face of body
  translate([0, 0, body_Z/2 + neck_Z/2 - overlap])
    cube([neck_X, neck_Y, neck_Z + 2*overlap], center=true);
}

module tab_with_hole() {
  // Tab above neck; through-hole along Y (visible in top/bottom views)
  difference() {
    translate([0, 0, body_Z/2 + neck_Z + tab_Z/2 - overlap])
      rbox([tab_X, tab_Y, tab_Z], tab_r);

    // Hole centered in tab
    translate([0, 0, body_Z/2 + neck_Z + tab_Z/2 - overlap])
      rotate([90, 0, 0])
        cylinder(d=hole_d, h=tab_Y + 2*overlap, center=true);
  }
}

module assembled() {
  union() {
    difference() {
      union() {
        body();
        latch_boss();
      }
      opposite_notch_cut();
    }
    neck();
    tab_with_hole();
  }
}

assembled();