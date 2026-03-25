// A extrusion bracket target size: [38, 31, 8.5]
// One connected solid (bracket + short extrusion stubs), with visible slots/holes.
// All placements are formula-based (no arbitrary offsets).

$fn = 64;

// Parameters
overall_length = 38;          // X
overall_width  = 31;          // Y
overall_thickness = 8.5;      // Z

hole_diameter = 5;
slot_length = 10;
slot_width  = 5;

corner_radius = 1.5;          // outer corner rounding
hole_edge_margin = 7;         // min edge margin for hole centers
slot_spacing_y = 14;          // distance between slot centerlines (Y)
attach_hole_spacing_x = 20;   // distance between hole centers (X)

overlap = 0.6;                // small overlap to ensure watertight unions/differences

// Simple extrusion stubs (for context + guaranteed connectivity)
extrusion_size = 20;
extrusion_stub_len = 26;      // short stubs so bracket remains clearly visible

// ---------- Helpers ----------
module rounded_plate_2d(L, W, r) {
  r2 = min(r, min(L, W)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - r2), sy*(W/2 - r2)]) circle(r=r2);
  }
}

module slot_2d(len, wid) {
  hull() {
    translate([-len/2, 0]) circle(r=wid/2);
    translate([ len/2, 0]) circle(r=wid/2);
  }
}

// ---------- Bracket ----------
module extrusion_bracket() {
  // Clamp feature positions so they always stay inside the plate
  x_hole = min(attach_hole_spacing_x/2, overall_length/2 - hole_edge_margin);
  y_slot = min(slot_spacing_y/2, overall_width/2 - hole_edge_margin);

  difference() {
    // Main plate with rounded corners
    linear_extrude(height=overall_thickness, center=true)
      rounded_plate_2d(overall_length, overall_width, corner_radius);

    // Through slots (two)
    for (sy = [-1, 1]) {
      translate([0, sy*y_slot, 0])
        linear_extrude(height=overall_thickness + 2*overlap, center=true)
          slot_2d(slot_length, slot_width);
    }

    // Through holes (two)
    for (sx = [-1, 1]) {
      translate([sx*x_hole, 0, 0])
        cylinder(h=overall_thickness + 2*overlap, r=hole_diameter/2, center=true);
    }
  }
}

// ---------- Extrusion stubs (connected to bracket) ----------
module extrusion_stubs_connected() {
  // Place stubs so they intersect the bracket slightly (overlap) to ensure one solid.
  // Stubs extend outward from the bracket edges in X and Y directions.
  x_pos = overall_length/2 + extrusion_stub_len/2 - overlap;
  y_pos = overall_width/2  + extrusion_stub_len/2 - overlap;
  z_pos = 0;

  union() {
    // X-direction stubs
    for (sx = [-1, 1])
      translate([sx*x_pos, 0, z_pos])
        cube([extrusion_stub_len, extrusion_size, extrusion_size], center=true);

    // Y-direction stubs
    for (sy = [-1, 1])
      translate([0, sy*y_pos, z_pos])
        cube([extrusion_size, extrusion_stub_len, extrusion_size], center=true);
  }
}

// ---------- Assembly (ONE connected solid) ----------
union() {
  extrusion_bracket();
  extrusion_stubs_connected();
}