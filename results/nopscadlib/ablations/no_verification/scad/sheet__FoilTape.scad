// Aluminium foil tape sheet (single connected solid, robust visibility)

// Parameters
tape_length = 100; //[50:200:1]
tape_width = 50; //[25:100:1]
tape_thickness = 0.08; //[0.04:0.16:0.01]
adhesive_ratio = 0.35; //[0.2:0.6:0.01]
corner_radius = 2; //[1:4:0.25]
edge_chamfer = 0.25; //[0.1:0.6:0.05]
texture_depth = 0.01; //[0.0:0.03:0.005]
texture_pitch = 6; //[3:12:1]
texture_groove_width = 0.6; //[0.3:1.2:0.1]
overlap = 0.5; //[0.2:2:0.1]

$fn = 64;

// Helpers
eps = 0.001;

// Keep geometry valid even for very thin tape
t  = max(tape_thickness, 0.02);
cr = min(corner_radius, min(tape_length, tape_width)/2 - eps);

// Chamfer/texture must never exceed thickness
ch = min(edge_chamfer, t*0.45);
td = min(texture_depth, t*0.35);

// 2D rounded rectangle
module rounded_rect_2d(L, W, R) {
  R2 = max(min(R, min(L, W)/2 - eps), 0);
  if (R2 <= eps) {
    square([L, W], center=true);
  } else {
    hull() {
      translate([ L/2 - R2,  W/2 - R2]) circle(r=R2);
      translate([-L/2 + R2,  W/2 - R2]) circle(r=R2);
      translate([-L/2 + R2, -W/2 + R2]) circle(r=R2);
      translate([ L/2 - R2, -W/2 + R2]) circle(r=R2);
    }
  }
}

// Main tape body with rounded corners
module tape_body() {
  linear_extrude(height=t, center=true, convexity=10)
    rounded_rect_2d(tape_length, tape_width, cr);
}

// Subtractive top chamfer (bevel) as a thin ring near the perimeter
module top_chamfer_cut() {
  if (ch > eps) {
    // Ensure inner profile remains valid
    inner_L = max(tape_length - 2*ch, eps);
    inner_W = max(tape_width  - 2*ch, eps);
    inner_R = max(cr - ch, 0);

    translate([0, 0, t/2 - ch/2])
      linear_extrude(height=ch + overlap, center=true, convexity=10)
        difference() {
          rounded_rect_2d(tape_length + 2*overlap, tape_width + 2*overlap, cr);
          rounded_rect_2d(inner_L, inner_W, inner_R);
        }
  }
}

// Subtractive surface grooves on the top face (kept shallow so sheet stays connected)
module surface_texture_cut() {
  if (td > eps && texture_pitch > eps && texture_groove_width > eps) {
    n = max(1, floor(tape_length/texture_pitch));
    for (i = [0:n]) {
      x = -tape_length/2 + i*texture_pitch;
      // Keep grooves inside the perimeter a bit to avoid edge artifacts
      translate([x, 0, t/2 - td/2])
        cube([texture_groove_width, tape_width - 2*eps, td + overlap], center=true);
    }
  }
}

// Final Output: one connected solid
difference() {
  tape_body();
  top_chamfer_cut();
  surface_texture_cut();
}