// Parameters
bbox_L = 0.15; //[0.075:0.3:0.005]
bbox_W = 0.13; //[0.065:0.26:0.005]
bbox_H = 0.08; //[0.04:0.16:0.005]
base_L = 0.15; //[0.075:0.3:0.005]
base_W = 0.13; //[0.065:0.26:0.005]
base_T = 0.02; //[0.01:0.04:0.001]
base_corner_R = 0.02; //[0.01:0.04:0.001]
rib_L = 0.09; //[0.045:0.18:0.005]
rib_W = 0.02; //[0.01:0.04:0.001]
rib_H = 0.05; //[0.025:0.1:0.002]
arm_thk = 0.02; //[0.01:0.04:0.001]
arm_width = 0.02; //[0.01:0.04:0.001]
arm_inner_R = 0.02; //[0.01:0.04:0.001]
arm_sweep_deg = 160; //[90:200:5]
tip_L = 0.02; //[0.01:0.04:0.001]
tip_W = 0.02; //[0.01:0.04:0.001]
tip_H = 0.02; //[0.01:0.04:0.001]
boss_L = 0.015; //[0.0075:0.03:0.001]
boss_W = 0.012; //[0.006:0.024:0.001]
boss_H = 0.015; //[0.0075:0.03:0.001]
boss_offset_Y = 0.018; //[0.009:0.036:0.001]
mount_hole_d = 0.01; //[0.005:0.02:0.001]
mount_hole_edge_margin = 0.03; //[0.015:0.06:0.001]
overlap = 0.001; //[0.0005:0.002:0.0001]
fillet_r = 0.003; //[0.001:0.01:0.0005]
arm_center_R = 0.03; //[0.015:0.06:0.001]

// Base Plate with Rounded Corners
module base_plate_rounded_rect() {
  union() {
    translate([0, 0, 0])
      cube([base_L - 2 * base_corner_R, base_W - 2 * base_corner_R, base_T], center = true);
    translate([base_L / 2 - base_corner_R, base_W / 2 - base_corner_R, 0])
      cylinder(r = base_corner_R, h = base_T, center = true);
    translate([base_L / 2 - base_corner_R, -(base_W / 2 - base_corner_R), 0])
      cylinder(r = base_corner_R, h = base_T, center = true);
    translate([-(base_L / 2 - base_corner_R), base_W / 2 - base_corner_R, 0])
      cylinder(r = base_corner_R, h = base_T, center = true);
    translate([-(base_L / 2 - base_corner_R), -(base_W / 2 - base_corner_R), 0])
      cylinder(r = base_corner_R, h = base_T, center = true);
  }
}

// Central Rib Strap with Side Bosses
module rib_with_bosses() {
  union() {
    translate([0, 0, base_T / 2 + rib_H / 2 - overlap])
      cube([rib_L, rib_W, rib_H], center = true);
    translate([0, boss_offset_Y, base_T / 2 + rib_H - boss_H / 2 - overlap])
      cube([boss_L, boss_W, boss_H], center = true);
    translate([0, -boss_offset_Y, base_T / 2 + rib_H - boss_H / 2 - overlap])
      cube([boss_L, boss_W, boss_H], center = true);
  }
}

// Curved Hook Arm with Tip
module hook_with_tip() {
  union() {
    minkowski() {
      translate([rib_L / 2 - overlap, 0, base_T / 2 + rib_H - arm_thk / 2 - overlap])
        rotate([90, 0, 0])
        rotate_extrude(angle = arm_sweep_deg)
        translate([arm_center_R, 0, 0])
        circle(r = arm_thk / 2);
      sphere(r = arm_thk / 2, center = true);
    }
    translate([rib_L / 2 + arm_center_R + tip_L / 2 - overlap, 0, base_T / 2 + rib_H - arm_thk / 2 - overlap])
      cube([tip_L, tip_W, tip_H], center = true);
    translate([rib_L / 2 - arm_thk / 2, 0, base_T / 2 + rib_H - arm_thk / 2 - overlap])
      sphere(r = arm_thk / 2, center = true);
  }
}

// Bracket with Mounting Holes
module bracket_with_mounting_holes() {
  difference() {
    union() {
      base_plate_rounded_rect();
      rib_with_bosses();
      hook_with_tip();
    }
    translate([-base_L / 2 + mount_hole_edge_margin, 0, 0])
      cylinder(r = mount_hole_d / 2, h = base_T + 2 * overlap, center = true);
    translate([base_L / 2 - mount_hole_edge_margin, 0, 0])
      cylinder(r = mount_hole_d / 2, h = base_T + 2 * overlap, center = true);
  }
}

// Final Bracket with Edge Fillets
module surface_texturing() {
  minkowski() {
    bracket_with_mounting_holes();
    sphere(r = fillet_r, center = true);
  }
}

// Render the final bracket
surface_texturing();