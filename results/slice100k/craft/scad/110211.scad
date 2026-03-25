$fn = 96;

// Bounding box (overall)
L = 22.0;
W = 15.0;
H = 6.0;

// Base plate (flat/plate-like)
plate_t = 4.0;                 // thickness of main plate
corner_r = 2.0;                // rounded outer corners

// Boss (centered, protrudes from top face)
boss_L = 10.0;
boss_W = 7.0;
boss_H = H - plate_t;          // ensures total height = H

// Through holes (simple round through-holes)
hole_d = 3.2;
hole_x_offset = 7.0;           // symmetric near ends
hole_y = 0.0;

// Rod seat (centered U-shaped cutout on bottom face)
u_radius = 4.0;                // rod radius
u_depth = 3.0;                 // how far up into the plate from bottom

overlap = 0.2;

// 2D rounded rectangle helper
module rounded_rect_2d(l, w, r) {
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
  }
}

// Base plate: simple rectangle with rounded corners (no ears/lobes)
module base_plate() {
  linear_extrude(height=plate_t, center=true)
    rounded_rect_2d(L, W, corner_r);
}

// Centered rectangular boss on top face (no minkowski bulking)
module boss() {
  translate([0, 0, plate_t/2 + boss_H/2 - overlap])
    cube([boss_L, boss_W, boss_H], center=true);
}

// Simple round through-holes
module through_holes() {
  for (sx = [-1, 1])
    translate([sx*hole_x_offset, hole_y, 0])
      cylinder(d=hole_d, h=H + 2*overlap, center=true);
}

// Centered semicylindrical (U-shaped) cutout spanning width (along Y)
module u_cutout() {
  // Create a half-cylinder "bite" from the bottom face, centered in X/Y.
  // Cylinder axis along Y; keep only the upper half (z >= 0 in local coords),
  // then place so its flat face coincides with the bottom surface.
  translate([0, 0, -plate_t/2 + u_depth])  // top of cut reaches up by u_depth
    intersection() {
      rotate([90, 0, 0])
        cylinder(r=u_radius, h=W + 2*overlap, center=true);
      // keep only half (local z >= 0) to make a U-shaped seat
      translate([0, 0, u_radius/2])
        cube([L + 2*overlap, W + 2*overlap, u_radius + 2*overlap], center=true);
    }
}

// Final part (one connected solid)
difference() {
  union() {
    base_plate();
    boss();
  }
  through_holes();
  u_cutout();
}