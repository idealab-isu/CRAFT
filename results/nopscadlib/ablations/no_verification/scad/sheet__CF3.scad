// Sheet: carbon fiber (visual approximation via dark color + subtle weave bump)
// One connected solid with rounded corners and 4 mounting holes

$fn = 96;

// Parameters
sheet_L = 300; //[150:600:1]
sheet_W = 200; //[100:400:1]
sheet_T = 2;   //[1:6:0.5]

corner_radius = 5;      //[0:30:0.5]
edge_round_r  = 0;      //[0:2:0.1]  // true 3D edge rounding (Minkowski). Keep small for performance.

hole_d = 6;             //[2:12:0.5]
hole_edge_margin = 15;  //[6:40:1]

op_overlap = 1;         //[0.5:2:0.1]

// Carbon-fiber-like surface bump (kept subtle; set to 0 to disable)
weave_texture_depth = 0.12; //[0:0.5:0.01]
weave_pitch = 6;            //[2:20:0.5]  // mm between weave bumps
weave_cell = 1.2;           //[0.5:4:0.1] // bump size

// ---------- Helpers ----------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module rounded_rect_2d(L, W, r) {
  r2 = clamp(r, 0, min(L, W)/2);
  if (r2 <= 0)
    square([L, W], center=true);
  else
    offset(r=r2) square([L - 2*r2, W - 2*r2], center=true);
}

module sheet_base() {
  // Robust, non-degenerate solid: linear_extrude of 2D rounded rectangle
  linear_extrude(height=sheet_T, center=true, convexity=10)
    rounded_rect_2d(sheet_L, sheet_W, corner_radius);
}

module sheet_with_edge_rounding() {
  if (edge_round_r > 0) {
    // Minkowski rounding increases overall size by 2*edge_round_r; compensate by shrinking base
    Ls = max(0.01, sheet_L - 2*edge_round_r);
    Ws = max(0.01, sheet_W - 2*edge_round_r);
    Ts = max(0.01, sheet_T - 2*edge_round_r);
    rs = clamp(corner_radius - edge_round_r, 0, min(Ls, Ws)/2);

    minkowski() {
      linear_extrude(height=Ts, center=true, convexity=10)
        rounded_rect_2d(Ls, Ws, rs);
      sphere(r=edge_round_r);
    }
  } else {
    sheet_base();
  }
}

module mounting_holes() {
  // 4 holes, positioned by formulas from dimensions
  hx = sheet_L/2 - hole_edge_margin;
  hy = sheet_W/2 - hole_edge_margin;

  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*hx, sy*hy, 0])
      cylinder(d=hole_d, h=sheet_T + 2*op_overlap, center=true);
}

module weave_bumps() {
  // Subtle raised weave on top face only (keeps one connected solid)
  if (weave_texture_depth > 0) {
    z0 = sheet_T/2 - weave_texture_depth/2; // sits on top surface
    nx = floor(sheet_L / weave_pitch) + 2;
    ny = floor(sheet_W / weave_pitch) + 2;

    intersection() {
      // Limit bumps to within the sheet outline
      sheet_with_edge_rounding();

      union() {
        for (ix = [-nx:nx], iy = [-ny:ny]) {
          // alternating offset to suggest weave
          ox = (iy % 2 == 0) ? 0 : weave_pitch/2;
          translate([ix*weave_pitch + ox, iy*weave_pitch, z0])
            cube([weave_cell, weave_pitch*0.85, weave_texture_depth], center=true);

          oy = (ix % 2 == 0) ? 0 : weave_pitch/2;
          translate([ix*weave_pitch, iy*weave_pitch + oy, z0])
            cube([weave_pitch*0.85, weave_cell, weave_texture_depth], center=true);
        }
      }
    }
  }
}

// ---------- Final ----------
color([0.06, 0.06, 0.07])  // dark carbon-fiber-like appearance
difference() {
  union() {
    sheet_with_edge_rounding();
    weave_bumps();
  }
  mounting_holes();
}