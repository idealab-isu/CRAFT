// Flexible shaft coupling: 6mm to 8mm bore, 19mm OD, 25mm long
// One connected solid; all placements derived from dimensions.

$fn = 128;

// --- Primary dimensions (mm)
OD = 19;
L  = 25;

// Bores
bore_A_d     = 6;     // end A
bore_B_d     = 8;     // end B
bore_A_depth = 12;
bore_B_depth = 12;

// Middle web between bores (keeps part connected)
center_web = 1.0;     // material thickness between the two bores

// Flex cuts (helical-ish slots around OD)
flex_cut_count        = 6;
flex_cut_width        = 1.2;
flex_cut_radial_depth = 3.2;
flex_cut_axial_len    = 20;
flex_cut_twist_deg    = 25;

// Clamp slit + screw (typical clamping style)
clamp_slit_w = 1.0;   // slit width
clamp_slit_depth = OD/2; // slit reaches to centerline (but not beyond)
set_screw_d = 3.0;
set_screw_z_offset = 4.0; // from each end face toward center

// Edge chamfer
chamfer_h = 0.8;
chamfer_radial = 0.8;

// Robust boolean overlap
eps = 0.2;

// --- Derived checks / constraints
bore_A_depth_eff = min(bore_A_depth, (L - center_web)/2);
bore_B_depth_eff = min(bore_B_depth, (L - center_web)/2);

// Bore centers (from part center, along Z)
bore_A_z = -L/2 + bore_A_depth_eff/2;
bore_B_z =  L/2 - bore_B_depth_eff/2;

// Clamp slit Z extents (each half)
slit_half_len = (L - center_web)/2;

// --- Base body
module coupling_body() {
  cylinder(h=L, r=OD/2, center=true);
}

// --- Bores (blind from each end, leaving center_web)
module bore_end_A() {
  translate([0,0,bore_A_z])
    cylinder(h=bore_A_depth_eff + eps, r=bore_A_d/2, center=true);
}

module bore_end_B() {
  translate([0,0,bore_B_z])
    cylinder(h=bore_B_depth_eff + eps, r=bore_B_d/2, center=true);
}

// --- Outer edge chamfers (simple 45-ish via conical subtraction)
module end_chamfer(zsign=1) {
  // zsign: +1 for +Z end, -1 for -Z end
  z0 = zsign*(L/2 - chamfer_h/2);
  translate([0,0,z0])
    difference() {
      cylinder(h=chamfer_h + eps, r=OD/2 + eps, center=true);
      cylinder(h=chamfer_h + 2*eps, r1=OD/2 - chamfer_radial, r2=OD/2 + eps, center=true);
    }
}

// --- Flex cut slot (hull between twisted top/bottom to suggest helix)
module flex_cut_slot() {
  // Slot positioned near OD, cutting inward by flex_cut_radial_depth
  x_center = (OD/2) - (flex_cut_radial_depth/2);
  slot_len = min(flex_cut_axial_len, L - 2*chamfer_h);

  hull() {
    translate([x_center, 0,  slot_len/2])
      rotate([0,0, flex_cut_twist_deg])
        cube([flex_cut_radial_depth + eps, flex_cut_width, slot_len], center=true);

    translate([x_center, 0, -slot_len/2])
      rotate([0,0,-flex_cut_twist_deg])
        cube([flex_cut_radial_depth + eps, flex_cut_width, slot_len], center=true);
  }
}

module helical_flex_cuts() {
  for (i=[0:flex_cut_count-1])
    rotate([0,0,i*360/flex_cut_count])
      flex_cut_slot();
}

// --- Clamp slits (one per end, do not cross center_web)
module clamp_slit_end(zsign=1) {
  // Slit runs along Z within one half, located at +X side
  zc = zsign*(center_web/2 + slit_half_len/2);
  translate([OD/2 - clamp_slit_depth/2, 0, zc])
    cube([clamp_slit_depth + eps, clamp_slit_w, slit_half_len + eps], center=true);
}

// --- Set screw holes (radial, one per end, aligned with clamp slit)
module set_screw_hole_end(zsign=1) {
  // Place along Z from each end face inward by set_screw_z_offset
  zc = zsign*(L/2 - set_screw_z_offset);
  // Drill along Y (radial), centered on +X side so it intersects the slit region
  translate([OD/2 - clamp_slit_depth + (set_screw_d/2), 0, zc])
    rotate([90,0,0])
      cylinder(h=OD + 2*eps, r=set_screw_d/2, center=true);
}

// --- Final model
module coupling() {
  difference() {
    // Main solid
    coupling_body();

    // Functional voids
    bore_end_A();
    bore_end_B();

    // Flexibility cuts
    helical_flex_cuts();

    // Clamp slits (one per end)
    clamp_slit_end(-1);
    clamp_slit_end( 1);

    // Set screw holes (one per end)
    set_screw_hole_end(-1);
    set_screw_hole_end( 1);

    // End chamfers (subtractive)
    end_chamfer(-1);
    end_chamfer( 1);
  }
}

coupling();