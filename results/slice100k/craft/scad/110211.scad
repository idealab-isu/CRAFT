$fn = 64;

// Bounding box target: 22 x 15 x 6 mm
L = 22.0;
W = 15.0;
H = 6.0;

// Base plate
plate_t  = 3.0;
corner_r = 2.0;

// Through holes (symmetric near ends)
hole_d     = 3.2;
hole_x_off = 7.0;
hole_y_off = 0.0;

// Center boss (on +Z face)
boss_L = 10.0;
boss_W = 7.0;
boss_H = 3.0;

// U-seat cutout (on -Z face)
u_r     = 4.0;
u_depth = 2.0;

// Small overlap to ensure watertight boolean ops
overlap = 0.2;

// 2D rounded rectangle (for clean rounded outer corners)
module rounded_rect_2d(l, w, r) {
  r2 = min(r, min(l, w)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(l/2 - r2), sy*(w/2 - r2)])
        circle(r = r2);
  }
}

module base_plate() {
  linear_extrude(height = plate_t, center = true)
    rounded_rect_2d(L, W, corner_r);
}

module boss() {
  // Boss sits on top face of plate: plate top at +plate_t/2
  translate([0, 0, plate_t/2 + boss_H/2 - overlap])
    cube([boss_L, boss_W, boss_H], center = true);
}

module through_holes() {
  for (sx = [-1, 1])
    translate([sx*hole_x_off, hole_y_off, 0])
      cylinder(d = hole_d, h = H + 2*overlap, center = true);
}

module u_seat_cutout() {
  // Create a semicylindrical (U-shaped) cut from the bottom face.
  // Cylinder axis along Y; only the portion that reaches into the plate by u_depth is removed.
  // Bottom face of plate is at z = -plate_t/2, so cylinder center is placed at:
  // zc = (-plate_t/2) + u_r - u_depth
  zc = -plate_t/2 + u_r - u_depth;

  translate([0, 0, zc])
    rotate([90, 0, 0])
      cylinder(r = u_r, h = W + 2*overlap, center = true);
}

difference() {
  union() {
    base_plate();
    boss();
  }
  through_holes();
  u_seat_cutout();
}