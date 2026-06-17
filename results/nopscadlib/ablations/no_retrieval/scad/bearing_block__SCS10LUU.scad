$fn = 32;

// =====================
// Parameters (mm)
// =====================
block_W = 40.0;   // X
block_L = 68.0;   // Y (shaft axis)
block_H = 20.0;   // Z

shaft_d = 8.0;
bore_clearance = 0.2;

bearing_pocket_d = 16.0;      // visible housing pocket around shaft
bearing_pocket_len = 52.0;    // along Y
bearing_pocket_clear = 0.2;

mount_hole_d = 4.5;
mount_hole_spacing_W = 30.0;  // X spacing
mount_hole_spacing_L = 58.0;  // Y spacing
counterbore_d = 9.0;
counterbore_depth = 4.0;

edge_chamfer = 1.0;

grease_port_d = 3.0;
grease_port_depth = 8.0;

set_screw_d = 3.0;
set_screw_depth = 12.0;

overlap = 0.6;

// =====================
// Derived / clamps
// =====================
shaft_r = (shaft_d + bore_clearance)/2;
bearing_pocket_r = (bearing_pocket_d + bearing_pocket_clear)/2;
bearing_pocket_len_eff = min(bearing_pocket_len, block_L - 2*edge_chamfer - 2);

// Ensure mounting holes stay inside the block
mount_x = min(mount_hole_spacing_W/2, block_W/2 - (counterbore_d/2 + 1));
mount_y = min(mount_hole_spacing_L/2, block_L/2 - (counterbore_d/2 + 1));

// =====================
// Base body (simplified, no hull)
// =====================
module body() {
  // Main block
  cube([block_W, block_L, block_H], center=true);

  // Raised housing (simple rectangular boss)
  housing_h = block_H*0.35;
  housing_w = min(block_W - 2*edge_chamfer, bearing_pocket_d + 10);
  housing_len = min(block_L - 2*edge_chamfer, bearing_pocket_len_eff + 10);

  translate([0, 0, block_H/2 + housing_h/2 - overlap])
    cube([housing_w, housing_len, housing_h], center=true);
}

// =====================
// Cuts
// =====================
module shaft_bore() {
  rotate([90, 0, 0])
    cylinder(h=block_L + 2*overlap, r=shaft_r, center=true);
}

module bearing_pocket() {
  rotate([90, 0, 0])
    cylinder(h=bearing_pocket_len_eff + 2*overlap, r=bearing_pocket_r, center=true);
}

module bearing_end_relief() {
  relief_depth = 2.0;
  relief_r = bearing_pocket_r + 1.0;

  for (sy = [-1, 1]) {
    translate([0, sy*(block_L/2 - relief_depth/2), 0])
      rotate([90, 0, 0])
        cylinder(h=relief_depth + overlap, r=relief_r, center=true);
  }
}

module mounting_cuts() {
  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([sx*mount_x, sy*mount_y, 0])
      cylinder(h=block_H + 2*overlap, r=mount_hole_d/2, center=true);

    translate([sx*mount_x, sy*mount_y, block_H/2 - counterbore_depth/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_d/2, center=true);
  }
}

module grease_port() {
  translate([0, 0, block_H/2 - grease_port_depth/2])
    cylinder(h=grease_port_depth + overlap, r=grease_port_d/2, center=true);
}

module set_screw() {
  // From +X face towards center, aimed at shaft centerline
  translate([block_W/2 - set_screw_depth/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=set_screw_depth + overlap, r=set_screw_d/2, center=true);
}

module edge_chamfers() {
  // Optional: disable for fastest render
  if (edge_chamfer > 0) {
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*(block_W/2 - edge_chamfer), sy*(block_L/2 - edge_chamfer), 0])
        rotate([0, 0, 45])
          cube([edge_chamfer*2, edge_chamfer*2, block_H + 2*overlap], center=true);
    }
  }
}

module all_cuts() {
  shaft_bore();
  bearing_pocket();
  bearing_end_relief();
  mounting_cuts();
  grease_port();
  set_screw();
  edge_chamfers();
}

// =====================
// Final
// =====================
difference() {
  union() { body(); }
  all_cuts();
}