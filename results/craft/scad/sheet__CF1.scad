// Carbon fiber sheet (fast render)
// Rounded rectangle via 2D offset + linear_extrude
// Optional weave relief simplified to 2D hatch extruded shallowly

$fn = 24;

// Parameters
sheet_length    = 200; //[100:400:1]
sheet_width     = 150; //[75:300:1]
sheet_thickness = 2;   //[1:6:0.5]
corner_radius   = 8;   //[2:20:1]

// Visual "weave" relief (kept cheap)
weave_enable    = true;
weave_depth     = 0.10; //[0.02:0.4:0.01]
weave_pitch     = 10;   //[3:12:0.5]
weave_bar_w     = 1.2;  //[0.5:3:0.1]
weave_margin    = 6;    //[0:20:1]
weave_angle     = 45;   //[0:90:1]
weave_second_dir = true;

eps = 0.02;

function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// 2D rounded rectangle using offset (fast, robust)
module rounded_rect_2d(L, W, R) {
  R2 = clamp(R, 0, min(L, W)/2 - eps);
  offset(r=R2)
    square([max(eps, L - 2*R2), max(eps, W - 2*R2)], center=true);
}

module sheet(L, W, T, R) {
  linear_extrude(height=T, center=true, convexity=3)
    rounded_rect_2d(L, W, R);
}

// 2D hatch pattern clipped to inner rectangle, then extruded shallowly
module weave_relief(L, W, T, depth, pitch, bar_w, margin, ang, second_dir=true) {
  innerL = L - 2*margin;
  innerW = W - 2*margin;

  if (innerL > eps && innerW > eps && depth > eps && pitch > eps && bar_w > eps) {
    z0 = T/2 - depth/2 - eps;

    // Keep bar count bounded for render safety
    diag = sqrt(innerL*innerL + innerW*innerW);
    n = min(40, ceil(diag/pitch) + 2);

    module bars2d(a) {
      rotate(a)
        for (i = [-n:n])
          translate([i*pitch, 0])
            square([bar_w, diag + 2*pitch], center=true);
    }

    translate([0,0,z0])
      linear_extrude(height=depth, center=true, convexity=2)
        intersection() {
          square([innerL, innerW], center=true);
          union() {
            bars2d(ang);
            if (second_dir) bars2d(-ang);
          }
        }
  }
}

union() {
  sheet(sheet_length, sheet_width, sheet_thickness, corner_radius);

  if (weave_enable)
    weave_relief(sheet_length, sheet_width, sheet_thickness,
                 weave_depth, weave_pitch, weave_bar_w, weave_margin, weave_angle,
                 second_dir=weave_second_dir);
}