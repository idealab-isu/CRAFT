// Dimension-calibrated (target: 23.12 x 10.31 x 72.41 mm)
scale([0.872491, 0.768684, 0.986419])
{
// Bounding box targets (mm)
bbox_X = 23.12; //[11.56:46.24:0.01]
bbox_Y = 10.31; //[5.155:20.62:0.01]
bbox_Z = 72.41; //[36.205:144.82:0.01]

// Main tapered arm (elongated along Z)
arm_L = bbox_Z; //[36.205:144.82:0.01]
arm_W_end1 = 8.5; //[4.25:17:0.01]   // X width near -Z
arm_W_end2 = 6;   //[3:12:0.01]      // X width near +Z
arm_T = 6.8;      //[3.4:13.6:0.01]  // Y thickness

// Fin / blade
fin_thk = 2; //[1:4:0.01]                 // thickness in X
fin_span = bbox_X; //[11.56:46.24:0.01]   // overall X span target (used to size fin reach)
fin_drop = bbox_Y; //[5.155:20.62:0.01]   // overall Y drop target (used for profile)
fin_L_along_arm = 18; //[9:36:0.01]       // length along Z
fin_pos_from_end = 6; //[3:12:0.01]       // from -Z end
fin_angle_deg = 35; //[10:70:1]           // rotate about X for acute angle
overlap = 1; //[0.5:2:0.1]

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// ---------- Base Shapes ----------
module tapered_prismatic_arm() {
  // True prismatic taper: hull between two end cross-sections at z = +/- arm_L/2
  hull() {
    translate([0, 0, -arm_L/2])
      cube([arm_W_end1, arm_T, overlap], center=true);
    translate([0, 0,  arm_L/2])
      cube([arm_W_end2, arm_T, overlap], center=true);
  }
}

// Fin profile in Y-Z, extruded in X (thickness)
module fin_profile_extrude(fin_reach_y) {
  // Right triangle in Y-Z: along +Z and down in -Y
  linear_extrude(height=fin_thk, center=true)
    polygon(points=[
      [0, 0],
      [fin_L_along_arm, 0],
      [0, -fin_reach_y]
    ]);
}

// ---------- Placement / Connectivity ----------
module triangular_fin_blade_connected() {
  // Size fin so overall X span stays within bbox_X:
  // total X extent ≈ max(arm width) + fin thickness + fin lateral offset.
  // Here fin is attached to +X side; its outer face should not exceed bbox_X/2.
  arm_max_w = max(arm_W_end1, arm_W_end2);
  fin_center_x = arm_max_w/2 + fin_thk/2 - overlap; // ensures overlap into arm
  x_outer = fin_center_x + fin_thk/2;
  x_target_outer = bbox_X/2;
  // If arm already exceeds bbox_X, keep fin minimal; otherwise keep within bbox.
  x_margin = x_target_outer - x_outer;
  // Use this margin to set fin vertical reach (visual blade size) but clamp to bbox_Y.
  fin_reach_y = clamp(fin_drop, 0.6*bbox_Y, bbox_Y);

  // Put fin root near -Z end; fin local Z runs [0..fin_L], so center at root + fin_L/2
  fin_root_z = -arm_L/2 + fin_pos_from_end;
  fin_center_z = fin_root_z + fin_L_along_arm/2;

  // Attach at mid-thickness in Y so rotation makes it project up/down
  fin_center_y = 0;

  // Interface "weld" block to guarantee manifold union (overlaps both parts)
  // Place at fin root, spanning across arm thickness and fin thickness.
  weld_x = arm_max_w/2 - overlap/2;
  weld_y = 0;
  weld_z = fin_root_z + overlap/2;

  union() {
    translate([fin_center_x, fin_center_y, fin_center_z])
      rotate([fin_angle_deg, 0, 0])
        fin_profile_extrude(fin_reach_y);

    translate([weld_x, weld_y, weld_z])
      cube([fin_thk + 2*overlap, arm_T + 2*overlap, fin_thk + 2*overlap], center=true);
  }
}

// ---------- Final Model ----------
union() {
  tapered_prismatic_arm();
  triangular_fin_blade_connected();
}
}
