$fn = 96;

// -------------------- Parameters (mm) --------------------
L = 0.11;                 // overall target length (approx)
W = 0.05;                 // overall target width (approx)
H = 0.04;                 // thickness

body_L = 0.06;
body_W = 0.038;
body_corner_r = 0.008;

tab_L = 0.025;
tab_W = 0.045;
tab_hole_d = 0.008;
tab_hole_spacing = 0.016;

clevis_L = 0.025;
clevis_outer_W = 0.045;
clevis_slot_W = 0.018;
clevis_slot_depth = 0.018;

diamond_flat_to_flat = 0.01;
diamond_rotation_deg = 45;

overlap = 0.001;

// -------------------- Helpers --------------------
module rounded_rect_2d(l, w, r) {
  r2 = min(r, min(l, w)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(l/2 - r2), sy*(w/2 - r2)]) circle(r=r2);
  }
}

module rounded_rect_3d(l, w, h, r) {
  linear_extrude(height=h, center=true)
    rounded_rect_2d(l, w, r);
}

// -------------------- Main body (barrel-like rounded rectangle) --------------------
module main_body_barrel() {
  // Slightly more "barrel" by bulging width at mid using hull of two rounded rectangles
  // (keeps it clearly rounded in top/bottom views)
  bulge = min(0.004, body_W*0.15);
  hull() {
    translate([-body_L*0.25, 0, 0])
      rounded_rect_3d(body_L*0.55, body_W, H, body_corner_r);
    translate([ body_L*0.25, 0, 0])
      rounded_rect_3d(body_L*0.55, body_W + bulge, H, body_corner_r);
  }
}

// -------------------- Mounting tab with rounded end --------------------
module mounting_tab_solid() {
  // Tab attaches to -X end of body with overlap
  x0 = -(body_L/2 + tab_L/2 - overlap);

  union() {
    // Rect portion
    translate([x0, 0, 0])
      cube([tab_L, tab_W, H], center=true);

    // Rounded end cap (semicircle) on the far -X end
    // Place a cylinder whose center is at the far end of the tab
    xcap = x0 - tab_L/2 + tab_W/2;
    translate([xcap, 0, 0])
      rotate([90, 0, 0])
        cylinder(r=tab_W/2, h=H, center=true);
  }
}

module mounting_tab_holes() {
  // Holes centered in tab, spaced along Y
  x0 = -(body_L/2 + tab_L/2 - overlap);
  for (sy = [-1, 1])
    translate([x0, sy*tab_hole_spacing/2, 0])
      cylinder(r=tab_hole_d/2, h=H + 2*overlap, center=true);
}

// -------------------- Clevis fork end (U-notch) --------------------
module clevis_fork_solid() {
  // Outer block attached to +X end of body with overlap
  x0 = (body_L/2 + clevis_L/2 - overlap);

  difference() {
    translate([x0, 0, 0])
      cube([clevis_L, clevis_outer_W, H], center=true);

    // U-shaped opening from the +X end inward:
    // subtract a rectangular slot that starts at the far +X face and goes inward by slot_depth
    // Use a slightly longer cutter in X and Z to guarantee clean subtraction.
    xslot = (body_L/2 + clevis_L - clevis_slot_depth/2 - overlap);
    translate([xslot, 0, 0])
      cube([clevis_slot_depth + 2*overlap, clevis_slot_W, H + 2*overlap], center=true);
  }
}

// -------------------- Center diamond through hole --------------------
module center_diamond_through_hole() {
  rotate([0, 0, diamond_rotation_deg])
    linear_extrude(height=H + 2*overlap, center=true)
      polygon(points=[
        [ diamond_flat_to_flat/2, 0],
        [0,  diamond_flat_to_flat/2],
        [-diamond_flat_to_flat/2, 0],
        [0, -diamond_flat_to_flat/2]
      ]);
}

// -------------------- Final assembly --------------------
module final_assembly() {
  difference() {
    union() {
      main_body_barrel();
      mounting_tab_solid();
      clevis_fork_solid();
    }
    mounting_tab_holes();
    center_diamond_through_hole();
  }
}

color("Silver") final_assembly();