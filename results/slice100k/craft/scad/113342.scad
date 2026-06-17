// Dimension-calibrated (target: 23.12 x 10.31 x 72.41 mm)
scale([0.917483, 0.538502, 0.969276])
{
// Slender tapered prismatic arm with an angled triangular fin/blade
// Target bounding box: 23.1 x 10.3 x 72.4 mm (X x Y x Z), elongated along Z

$fn = 64;

// --- Target bbox ---
bbox_x = 23.12;
bbox_y = 10.31;
bbox_z = 72.41;

// --- Main arm (tapered) ---
arm_L      = bbox_z;
arm_W_end1 = bbox_x;   // X at fin end (max X)
arm_W_end2 = 16.0;     // X at far end
arm_T_end1 = bbox_y;   // Y thickness at fin end (max Y)
arm_T_end2 = 7.0;      // Y thickness at far end

// --- Fin / blade (make it more visible) ---
fin_thk    = 2.0;      // thickness (along X after rotation)
fin_span   = 12.0;     // extent away from arm (local +X in fin 2D)
fin_height = 14.0;     // extent up/down (local +Y in fin 2D)
fin_pos_from_end = 9.0; // from near end along +Z
fin_y_tilt_deg   = 25;  // acute tilt about Y to create kinked/L profile
overlap = 1.0;          // overlap for watertight union

// ---------- Main arm ----------
module tapered_arm() {
  // Hull of two thin slices to create a tapered prismatic bar
  slice = max(1.2, arm_L*0.04);
  hull() {
    translate([0, 0, -arm_L/2 + slice/2])
      cube([arm_W_end1, arm_T_end1, slice], center=true);
    translate([0, 0,  arm_L/2 - slice/2])
      cube([arm_W_end2, arm_T_end2, slice], center=true);
  }
}

// ---------- Fin ----------
module fin_plate() {
  // 2D triangle in XY, extruded along Z; then rotate so thickness is along X
  rotate([0, 90, 0])  // extrusion axis -> X
    linear_extrude(height=fin_thk, center=true, convexity=10)
      polygon(points=[[0,0],[fin_span,0],[0,fin_height]]);
}

module fin_placed() {
  // Attach to +X face near the near end; centered in Y so it reads in more views
  x_attach = arm_W_end1/2 - fin_thk/2 + overlap;  // overlap into arm
  y_attach = 0;
  z_attach = -arm_L/2 + fin_pos_from_end;

  translate([x_attach, y_attach, z_attach])
    rotate([0, fin_y_tilt_deg, 0])  // acute angle -> kinked/L profile
      fin_plate();
}

// Root gusset to guarantee connectivity and make the fin less subtle
module fin_root_gusset() {
  gus_x = fin_thk + 2*overlap;
  gus_y = min(arm_T_end1, 6.0);
  gus_z = 6.0;

  x_attach = arm_W_end1/2 - gus_x/2 + overlap;
  y_attach = 0;
  z_attach = -arm_L/2 + fin_pos_from_end + gus_z/2 - overlap;

  translate([x_attach, y_attach, z_attach])
    rotate([0, fin_y_tilt_deg, 0])
      cube([gus_x, gus_y, gus_z], center=true);
}

// ---------- Final ----------
union() {
  tapered_arm();
  fin_placed();
  fin_root_gusset();
}
}
