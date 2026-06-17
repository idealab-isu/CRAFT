// Dimension-calibrated (target: 19.50 x 18.88 x 78.50 mm)
scale([1.227503, 1.032839, 1.028064])
{
$fn = 128;

// =====================
// Parameters (mm)
// =====================
L = 78.5;                 // overall length (Z)
OD_x = 19.5;              // target bounding box X
OD_y = 18.88;             // target bounding box Y
ID = 14;                  // base inner diameter
slit_w = 2;               // axial slit width

// Internal steps/notches near one end (annular counterbores)
step_count = 3;           // number of internal steps
step_axial_len = 2;       // axial length of each step
step_radial_depth = 0.4;  // radial increase per step
step_start_from_end = 0.5;// offset from end to first step

// Bore lead-in at same end
bore_lead_len = 3;        // lead-in length
bore_lead_extra_d = 1;    // lead-in extra diameter

// Outer end chamfer
edge_chamfer = 0.6;       // outer end chamfer height

// Robust boolean overlap
overlap = 1.5;            // 1–2mm recommended

// =====================
// Derived
// =====================
OD_r = min(OD_x, OD_y)/2; // keep outer cylindrical
ID_r = ID/2;

// Ensure stepped features fit within length (simple guard)
steps_total_len = step_count * step_axial_len;
assert(bore_lead_len + step_start_from_end + steps_total_len <= L,
       "Internal step/lead-in lengths exceed part length.");

// =====================
// Base Shapes
// =====================
module outer_tube_body() {
  cylinder(h=L, r=OD_r, center=true);
}

module inner_bore_base_cut() {
  cylinder(h=L + 2*overlap, r=ID_r, center=true);
}

// Full-length axial slit (C-shaped cross-section)
module full_length_axial_slit_cut() {
  // Slot fully crosses the wall and runs full length.
  // Positioned so it opens the ring on +X side.
  translate([OD_r - slit_w/2, 0, 0])
    cube([slit_w + 2*overlap, 2*OD_r + 4*overlap, L + 4*overlap], center=true);
}

// Internal steps/notches near one end of the bore (annular counterbores)
// Implemented as a stack of short cylinders that enlarge the bore near -Z end.
module internal_steps_near_one_end_cut() {
  union() {
    for (n = [1:step_count]) {
      r_step = ID_r + step_radial_depth * n;

      // Steps start near -Z end and progress inward along +Z
      z0 = -L/2 + step_start_from_end;                 // start position from -Z end
      z_center = z0 + (n-1)*step_axial_len + step_axial_len/2;

      translate([0, 0, z_center])
        cylinder(h=step_axial_len + 2*overlap, r=r_step, center=true);
    }
  }
}

// Lead-in taper on bore at the same (-Z) end
module lead_in_taper_on_bore_cut() {
  // Starts exactly at -Z end and extends inward
  z_center = -L/2 + bore_lead_len/2;

  translate([0, 0, z_center])
    cylinder(h=bore_lead_len + 2*overlap,
             r1=ID_r + bore_lead_extra_d/2,
             r2=ID_r,
             center=true);
}

// Outer end chamfers (simple bevels)
module outer_chamfers_cut() {
  union() {
    // -Z end chamfer
    translate([0, 0, -L/2 + edge_chamfer/2])
      cylinder(h=edge_chamfer + 2*overlap,
               r1=OD_r + overlap,
               r2=max(OD_r - edge_chamfer, 0.01),
               center=true);

    // +Z end chamfer
    translate([0, 0,  L/2 - edge_chamfer/2])
      cylinder(h=edge_chamfer + 2*overlap,
               r1=max(OD_r - edge_chamfer, 0.01),
               r2=OD_r + overlap,
               center=true);
  }
}

// =====================
// Final Model (single connected solid)
// =====================
module complete_model() {
  difference() {
    outer_tube_body();

    union() {
      // Base bore
      inner_bore_base_cut();

      // Internal stepped/notched features near one end (visible in section/end view)
      lead_in_taper_on_bore_cut();
      internal_steps_near_one_end_cut();

      // Full-length slit
      full_length_axial_slit_cut();

      // Outer chamfers
      outer_chamfers_cut();
    }
  }
}

complete_model();
}
