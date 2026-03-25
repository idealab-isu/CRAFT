// Sheet carbon fiber (single connected solid)

// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 150;  //[75:300:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 8;  //[4:16:1]
edge_chamfer = 0.8; //[0.3:2:0.1]
texture_depth = 0.15; //[0.05:0.4:0.05]
texture_pitch = 12; //[6:24:1]
texture_bump_radius = 2; //[1:4:0.5]
texture_margin = 10; //[5:25:1]
overlap = 1; //[0.5:2:0.1]

$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// 2D rounded rectangle (for robust extrusion)
module rounded_rect_2d(L, W, R) {
  R2 = clamp(R, 0, min(L, W)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - R2), sy*(W/2 - R2)])
        circle(r=R2);
  }
}

// Base plate with rounded corners and slight edge chamfer (via 2D offset)
module plate() {
  // Keep chamfer within feasible range
  ch = clamp(edge_chamfer, 0, min(sheet_length, sheet_width)/10);

  linear_extrude(height=sheet_thickness, center=true, convexity=10)
    offset(delta=ch)
      rounded_rect_2d(sheet_length - 2*ch, sheet_width - 2*ch, corner_radius - ch);
}

// Surface texture: shallow dimples on top face, kept inside margins
module texture_dimples() {
  // Ensure at least one dimple and valid spacing
  usable_L = max(0, sheet_length - 2*texture_margin);
  usable_W = max(0, sheet_width  - 2*texture_margin);

  nx = max(1, floor(usable_L / texture_pitch));
  ny = max(1, floor(usable_W / texture_pitch));

  // Center the grid within the usable area
  x0 = - (nx - 1) * texture_pitch / 2;
  y0 = - (ny - 1) * texture_pitch / 2;

  // Place dimples so they cut into the top surface (connected solid remains)
  zpos = sheet_thickness/2 - texture_depth/2 + overlap/2;

  for (ix = [0:nx-1])
    for (iy = [0:ny-1])
      translate([x0 + ix*texture_pitch, y0 + iy*texture_pitch, zpos])
        cylinder(r=texture_bump_radius, h=texture_depth + overlap, center=true);
}

// Final output
module final_sheet() {
  difference() {
    plate();
    texture_dimples();
  }
}

color([0.1, 0.1, 0.1]) final_sheet();