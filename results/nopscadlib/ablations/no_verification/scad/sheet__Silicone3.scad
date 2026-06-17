// Sheet silicone (plain sheet, single connected solid, no text/labels)
// Fixes:
// - Removed perforation/texture pattern and central raised pad
// - Simple rounded-rectangle sheet with optional subtle edge fillet/chamfer-like bevel
// - One watertight solid

// ---------- Parameters ----------
sheet_length    = 200; //[100:400:1]
sheet_width     = 150; //[75:300:1]
sheet_thickness = 2;   //[1:6:0.5]

corner_radius   = 5;   //[0:20:0.5]
corner_segments = 48;  //[8:128:1]

// Small bevel amount (0 = none). Implemented as a true cut.
edge_bevel      = 0.4; //[0:2:0.05]

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

$fn = corner_segments;

r_eff = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2);

// 2D rounded rectangle (watertight via hull)
module rounded_rect_2d(L, W, R) {
  if (R <= 0) {
    square([L, W], center=true);
  } else {
    hull() {
      for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(L/2 - R), sy*(W/2 - R)])
          circle(r=R);
    }
  }
}

// Base sheet
module sheet_body() {
  linear_extrude(height=sheet_thickness, center=true, convexity=10)
    rounded_rect_2d(sheet_length, sheet_width, r_eff);
}

// Optional subtle bevel by subtracting a slightly smaller, slightly taller inner solid
module sheet_with_bevel() {
  b = clamp(edge_bevel, 0, min(sheet_thickness/2, min(sheet_length, sheet_width)/10));
  if (b <= 0) {
    sheet_body();
  } else {
    difference() {
      sheet_body();
      // Inner cut removes material near the perimeter on both faces, leaving a beveled rim
      linear_extrude(height=sheet_thickness + 2*b, center=true, convexity=10)
        rounded_rect_2d(
          sheet_length - 2*b,
          sheet_width  - 2*b,
          max(r_eff - b, 0)
        );
    }
  }
}

// ---------- Final Model ----------
color([0.92, 0.92, 0.88, 0.65])
sheet_with_bevel();