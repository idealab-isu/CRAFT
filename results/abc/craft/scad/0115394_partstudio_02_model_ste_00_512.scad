// Dimension-calibrated (target: 0.13 x 0.11 x 0.03 mm)
scale([1.080594, 1.270699, 5.424253])
{
$fn = 96;

// --- Target bounding box (approx): 0.1 x 0.1 x ~0 (very thin plate-like) ---
L = 0.10;                 // X
W = 0.10;                 // Y
T = 0.004;                // Z (thin but nonzero so it renders)

// Fillet radius (rounded rectangle)
corner_r = 0.012;

// Recess/decor pattern (shallow, must be visible)
recess_depth   = 0.0010;  // increased so it shows in ortho renders
recess_margin  = 0.012;
recess_line_W  = 0.004;

// Tabs (rectangular protrusions on ONE face)
tab_count = 5;
tab_L     = 0.010;
tab_W     = 0.006;
tab_H     = 0.0022;       // slightly taller so they read as protrusions
tab_gap   = 0.004;

// Placement: tabs along +Y edge, centered in X
tab_edge_inset = 0.002;   // how far tabs sit in from the outer +Y edge
overlap = 0.0003;         // ensures watertight unions/differences

// ---------- Helpers ----------
module rounded_rect_2d(l, w, r) {
  // Filleted rectangle using offset
  offset(r=r) offset(delta=-r)
    square([l, w], center=true);
}

module plate_body() {
  linear_extrude(height=T, center=true)
    rounded_rect_2d(L, W, corner_r);
}

// Shallow recessed pattern on a face (engraved into that face only)
module recess_pattern(zsign=+1) {
  // zsign: +1 engrave from top, -1 engrave from bottom
  // Place cutter so it intersects only the intended face region.
  zc = zsign*(T/2 - recess_depth/2);

  translate([0, 0, zc]) union() {
    // Cross
    cube([L - 2*recess_margin, recess_line_W, recess_depth + overlap], center=true);
    cube([recess_line_W, W - 2*recess_margin, recess_depth + overlap], center=true);

    // Inner frame (thin rectangular ring) to make relief clearly visible
    difference() {
      linear_extrude(height=recess_depth + overlap, center=true)
        offset(delta=recess_line_W/2)
          rounded_rect_2d(L - 2*recess_margin, W - 2*recess_margin, max(0, corner_r - recess_margin/2));
      linear_extrude(height=recess_depth + overlap + 2*overlap, center=true)
        rounded_rect_2d(L - 2*(recess_margin + recess_line_W), W - 2*(recess_margin + recess_line_W),
                        max(0, corner_r - recess_margin/2 - recess_line_W));
    }
  }
}

// Rectangular tabs protruding from the BOTTOM face (one opposite face)
module tab_row() {
  // Total span of tabs+gaps
  span = tab_count*tab_L + (tab_count-1)*tab_gap;

  // Center the row in X
  x0 = -span/2 + tab_L/2;

  // Place tabs near +Y edge, protruding downward from bottom face
  y_center = (W/2 - tab_edge_inset - tab_W/2);
  z_center = (-T/2 - tab_H/2 + overlap); // overlap into plate for connectivity

  for (i = [0:tab_count-1]) {
    translate([x0 + i*(tab_L + tab_gap), y_center, z_center])
      cube([tab_L, tab_W, tab_H], center=true);
  }
}

// ---------- Complete model ----------
module complete_model() {
  union() {
    difference() {
      plate_body();
      // Recesses on both large faces (decorative shallow relief)
      recess_pattern(+1);
      recess_pattern(-1);
    }
    // Tabs on one face only (bottom)
    tab_row();
  }
}

color([0.85, 0.85, 0.8]) complete_model();
}
