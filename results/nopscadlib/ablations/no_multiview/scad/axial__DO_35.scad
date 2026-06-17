// A axial: [3.4, 1.75, 0.3]
// Simple, clearly axial (rotationally symmetric) part:
// - Outer cylinder: length = 3.4, OD = 1.75
// - Central through-bore sized by wall_thickness (0.3) -> ID = OD - 2*wall
// - Small end chamfers for a clean silhouette
// All geometry is a single connected solid; no floating parts.

$fn = 96;

// Parameters (match request)
body_length     = 3.4;   // axial length
body_od         = 1.75;  // outer diameter
wall_thickness  = 0.3;   // radial wall thickness (sets bore)

// Derived
body_r  = body_od/2;
body_id = max(0.01, body_od - 2*wall_thickness);
bore_r  = body_id/2;

// Small, proportional chamfer (kept simple)
chamfer_len = min(0.25, body_length*0.12);
eps = 0.02; // slight overlap for robust booleans

module axial_part() {
  difference() {
    // Outer body with simple end chamfers (still rotationally symmetric)
    union() {
      // Main straight section
      cylinder(h = body_length - 2*chamfer_len, r = body_r, center = true);

      // Top chamfer frustum
      translate([0,0,(body_length/2 - chamfer_len/2)])
        cylinder(h = chamfer_len + eps, r1 = body_r, r2 = max(0.01, body_r - chamfer_len), center = true);

      // Bottom chamfer frustum
      translate([0,0,(-body_length/2 + chamfer_len/2)])
        cylinder(h = chamfer_len + eps, r1 = max(0.01, body_r - chamfer_len), r2 = body_r, center = true);
    }

    // Central through-bore (axial feature)
    cylinder(h = body_length + 2*eps, r = bore_r, center = true);
  }
}

axial_part();