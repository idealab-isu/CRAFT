// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
corner_radius = 8;  //[2:20:1]
edge_chamfer = 0.8; //[0.2:3:0.1]
texture_depth = 0.15; //[0.05:0.4:0.01]
texture_pitch = 6;  //[3:12:0.5]
texture_groove_width = 1.2; //[0.5:3:0.1]
texture_margin = 6; //[0:20:1]
overlap = 1;        //[0.5:2:0.1]

$fn = 96;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Rounded rectangle sheet (single connected solid)
module rounded_sheet(L, W, T, R) {
  R2 = clamp(R, 0, min(L, W)/2 - 0.01);
  linear_extrude(height=T, center=true, convexity=10)
    offset(r=R2)
      square([L - 2*R2, W - 2*R2], center=true);
}

// Chamfer by subtracting wedges along all 4 edges (keeps solid connected)
module chamfered_sheet(L, W, T, R, C) {
  C2 = clamp(C, 0, T/2 - 0.001);
  difference() {
    rounded_sheet(L, W, T, R);

    // Long edges (along X)
    for (sy = [-1, 1]) {
      translate([0, sy*(W/2 - C2/2), 0])
        rotate([0, sy*90, 0])
          linear_extrude(height=L + 2*overlap, center=true, convexity=10)
            polygon(points=[[0,0],[C2,0],[0,T]]);
    }

    // Short edges (along Y)
    for (sx = [-1, 1]) {
      translate([sx*(L/2 - C2/2), 0, 0])
        rotate([0, -sx*90, 90])
          linear_extrude(height=W + 2*overlap, center=true, convexity=10)
            polygon(points=[[0,0],[C2,0],[0,T]]);
    }
  }
}

// Surface texture grooves (subtractive, shallow)
module texture_grooves(L, W, T) {
  usable_w = W - 2*texture_margin;
  usable_l = L - 2*texture_margin;
  if (usable_w > 0 && usable_l > 0) {
    n = floor(usable_w / texture_pitch);
    for (k = [-n:n]) {
      y = k * texture_pitch;
      if (abs(y) <= usable_w/2 - texture_groove_width/2) {
        translate([0, y, T/2 - texture_depth/2])
          cube([usable_l, texture_groove_width, texture_depth + overlap], center=true);
      }
    }
  }
}

// Final sheet
module final_sheet() {
  difference() {
    chamfered_sheet(sheet_length, sheet_width, sheet_thickness, corner_radius, edge_chamfer);
    texture_grooves(sheet_length, sheet_width, sheet_thickness);
  }
}

// Render
color([0.08, 0.08, 0.09])
final_sheet();