$fn = 96;

// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150;  //[75:300:1]
sheet_thickness = 2; //[1:4:0.1]
corner_radius = 12; //[6:24:1]
edge_chamfer = 0.6; //[0.2:1.2:0.1]
texture_depth = 0.15; //[0.05:0.4:0.05]
texture_pitch = 12; //[6:24:1]
texture_radius = 2.5; //[1.5:5:0.1]
overlap = 1; //[0.5:2:0.1]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);
cr = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2 - 0.01);
ch = clamp(edge_chamfer, 0, min(sheet_length, sheet_width)/2 - 0.01);
td = clamp(texture_depth, 0, sheet_thickness - 0.01);

// Rounded rectangle 2D
module rounded_rect_2d(L, W, R) {
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - R), sy*(W/2 - R)]) circle(r=R);
  }
}

// Base sheet with rounded corners (single connected solid)
module sheet_base() {
  linear_extrude(height=sheet_thickness, center=true, convexity=10)
    rounded_rect_2d(sheet_length, sheet_width, cr);
}

// Edge chamfer approximation: subtract a slightly smaller rounded slab from top+bottom
module edge_chamfer_cut() {
  // Keep at least a tiny footprint so we don't erase the whole sheet
  innerL = max(0.01, sheet_length - 2*ch);
  innerW = max(0.01, sheet_width  - 2*ch);
  innerR = max(0.01, cr - ch);

  union() {
    // Top cut
    translate([0, 0, sheet_thickness/2 - ch/2])
      linear_extrude(height=ch + 2*overlap, center=true, convexity=10)
        rounded_rect_2d(innerL, innerW, innerR);

    // Bottom cut
    translate([0, 0, -sheet_thickness/2 + ch/2])
      linear_extrude(height=ch + 2*overlap, center=true, convexity=10)
        rounded_rect_2d(innerL, innerW, innerR);
  }
}

// Texture dimples (subtractive), placed on top surface
module surface_texture(x_offset, y_offset) {
  translate([x_offset, y_offset, sheet_thickness/2 - td/2])
    cylinder(r=texture_radius, h=td + 2*overlap, center=true);
}

module sheet_textured() {
  difference() {
    difference() {
      sheet_base();
      edge_chamfer_cut();
    }

    // 2x2 sample texture (kept from original intent)
    surface_texture(-texture_pitch/2, -texture_pitch/2);
    surface_texture( texture_pitch/2, -texture_pitch/2);
    surface_texture(-texture_pitch/2,  texture_pitch/2);
    surface_texture( texture_pitch/2,  texture_pitch/2);
  }
}

// Final output
color([0.85, 0.85, 0.8])
sheet_textured();