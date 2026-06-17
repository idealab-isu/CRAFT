// Sheet DiBond (plain single connected solid)

// Parameters
sheet_length = 1000; //[500:2000:1]
sheet_width = 500; //[250:1000:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 0; //[0:50:1]
edge_chamfer = 0; //[0:5:0.5]

// Plain sheet request: no holes/markers by default
mount_hole_diameter = 6; //[2:20:0.5]
mount_hole_edge_offset = 20; //[5:100:1]
mount_hole_count = 0; //[0:4:1]
marking_depth = 0; //[0:1:0.1]
marking_margin = 30; //[5:150:1]

overlap = 0.5; //[0.1:2:0.1]

$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

r_eff  = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2);
ch_eff = clamp(edge_chamfer, 0, min(sheet_length, sheet_width, sheet_thickness)/2);
hole_r = mount_hole_diameter/2;

// 2D rounded rectangle
module rounded_rect_2d(L, W, R) {
  R2 = clamp(R, 0, min(L, W)/2);
  if (R2 <= 0) {
    square([L, W], center=true);
  } else {
    hull() {
      for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(L/2 - R2), sy*(W/2 - R2)]) circle(r=R2);
    }
  }
}

// Base sheet (extruded 2D profile)
module sheet_solid() {
  linear_extrude(height=sheet_thickness, center=true)
    rounded_rect_2d(sheet_length, sheet_width, r_eff);
}

// Optional mounting holes (through)
module mounting_holes() {
  x = sheet_length/2 - mount_hole_edge_offset;
  y = sheet_width/2  - mount_hole_edge_offset;

  if (mount_hole_count == 4 && x > hole_r && y > hole_r) {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*x, sy*y, 0])
        cylinder(r=hole_r, h=sheet_thickness + 2*overlap, center=true);
  }
}

// Optional surface marking (shallow pocket on top face)
module surface_marking() {
  Lm = sheet_length - 2*marking_margin;
  Wm = sheet_width  - 2*marking_margin;

  if (marking_depth > 0 && Lm > 0 && Wm > 0) {
    translate([0, 0, sheet_thickness/2 - marking_depth/2])
      linear_extrude(height=marking_depth + overlap, center=true)
        rounded_rect_2d(Lm, Wm, max(r_eff - marking_margin, 0));
  }
}

// Optional edge chamfer (simple bevel approximation via hull of two profiles)
module chamfered_sheet() {
  if (ch_eff <= 0) {
    sheet_solid();
  } else {
    // Ensure valid inner dimensions
    L2 = max(sheet_length - 2*ch_eff, 0.01);
    W2 = max(sheet_width  - 2*ch_eff, 0.01);
    R2 = max(r_eff - ch_eff, 0);

    hull() {
      // Bottom face profile (full size)
      translate([0, 0, -sheet_thickness/2])
        linear_extrude(height=0.01, center=false)
          rounded_rect_2d(sheet_length, sheet_width, r_eff);

      // Top face profile (shrunk by chamfer amount)
      translate([0, 0,  sheet_thickness/2])
        linear_extrude(height=0.01, center=false)
          rounded_rect_2d(L2, W2, R2);
    }
  }
}

// Final Model (single connected solid)
module complete_model() {
  difference() {
    chamfered_sheet();
    mounting_holes();
    surface_marking();
  }
}

// Render
color([0.75, 0.75, 0.77]) complete_model();