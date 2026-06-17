// Threaded heat-set insert (simplified but structurally correct)
// Spec: 30.0mm OD, 22.0mm length, internal thread/bore for 12.0mm screw (M12 visual approximation)

$fn = 180;

// -------------------- Parameters --------------------
od = 30.0;                 // outer diameter
L  = 22.0;                 // overall length

thread_nom_d   = 12.0;     // nominal screw diameter (internal thread major diameter)
thread_pitch   = 1.75;     // pitch (visual)
thread_length  = 20.0;     // threaded length inside insert (<= L)

bore_minor_d   = 10.2;     // minor diameter of internal thread (tap drill-ish)

lead_in_chamfer_d = 13.0;  // entry chamfer diameter
lead_in_chamfer_h = 1.0;   // entry chamfer height

runout_relief_d = 12.5;    // relief diameter near ends
runout_relief_h = 1.0;     // relief height near ends

outer_edge_chamfer_h  = 1.0;
outer_edge_chamfer_d2 = 28.0;

barb_count   = 24;
barb_radial  = 1.2;        // how far barbs protrude beyond OD/2
barb_width   = 2.0;        // tangential width
barb_height  = 16.0;       // axial height of barb band
barb_band_offset = 0.0;    // axial offset of barb band center

// Thread geometry (subtracted helix to ensure visible through-bore + thread form)
thread_depth = 0.65;          // radial depth of thread groove into bore
thread_profile_width  = 1.0;  // tangential width of groove cutter
thread_profile_height = 1.0;  // axial thickness of groove cutter

connect_overlap = 1.2;     // overlap for robust unions/differences (1-2mm)

// -------------------- Derived --------------------
thread_major_r = thread_nom_d/2;
bore_minor_r   = bore_minor_d/2;

// Keep thread within part (avoid lead-in chamfers)
thread_length_eff = min(thread_length, L - 2*lead_in_chamfer_h);
thread_z0 = -thread_length_eff/2;
thread_z1 =  thread_length_eff/2;

// Helix resolution
thread_steps = max(ceil(thread_length_eff / (thread_pitch/10)), 120); // ~10 segments per pitch minimum

// -------------------- Modules --------------------
module insert_main_body() {
  cylinder(r=od/2, h=L, center=true);
}

module outer_edge_chamfer_top() {
  // Ensure chamfer overlaps the main body
  translate([0, 0, L/2 - outer_edge_chamfer_h/2])
    cylinder(r1=od/2, r2=outer_edge_chamfer_d2/2,
             h=outer_edge_chamfer_h + connect_overlap, center=true);
}

module outer_edge_chamfer_bottom() {
  // Ensure chamfer overlaps the main body
  translate([0, 0, -L/2 + outer_edge_chamfer_h/2])
    cylinder(r1=outer_edge_chamfer_d2/2, r2=od/2,
             h=outer_edge_chamfer_h + connect_overlap, center=true);
}

module external_barb_tooth() {
  // Radial placement: inner face slightly inside the OD so it fuses to the body
  // Inner face radius = od/2 - connect_overlap
  // Cube radial half-size = (barb_radial + connect_overlap)/2
  // Center radius = (od/2 - connect_overlap) + (barb_radial + connect_overlap)/2
  r_center = (od/2 - connect_overlap) + (barb_radial + connect_overlap)/2;

  translate([r_center, 0, barb_band_offset])
    cube([barb_radial + connect_overlap, barb_width, barb_height], center=true);
}

module internal_bore_base() {
  // Through-bore (slightly longer for clean subtraction)
  cylinder(r=bore_minor_r, h=L + 2*connect_overlap, center=true);
}

module thread_lead_in_chamfer_top() {
  // Chamfer overlaps the end face and meets the bore
  translate([0, 0, L/2 - lead_in_chamfer_h/2])
    cylinder(r1=lead_in_chamfer_d/2, r2=bore_minor_r,
             h=lead_in_chamfer_h + connect_overlap, center=true);
}

module thread_lead_in_chamfer_bottom() {
  translate([0, 0, -L/2 + lead_in_chamfer_h/2])
    cylinder(r1=bore_minor_r, r2=lead_in_chamfer_d/2,
             h=lead_in_chamfer_h + connect_overlap, center=true);
}

module bore_relief_runout_top() {
  translate([0, 0, L/2 - runout_relief_h/2])
    cylinder(r=runout_relief_d/2,
             h=runout_relief_h + connect_overlap, center=true);
}

module bore_relief_runout_bottom() {
  translate([0, 0, -L/2 + runout_relief_h/2])
    cylinder(r=runout_relief_d/2,
             h=runout_relief_h + connect_overlap, center=true);
}

module internal_thread_groove_segment() {
  // Cutter segment that removes material from the bore to form a visible internal thread.
  // Ensure it actually intersects the bore wall by centering it near the major radius.
  // Make it slightly "taller" axially to avoid gaps between steps.
  seg_r = (bore_minor_r + thread_major_r)/2;

  translate([seg_r, 0, 0])
    cube([
      (thread_major_r - bore_minor_r) + 2*thread_depth,
      thread_profile_width,
      thread_profile_height + 0.6
    ], center=true);
}

module internal_thread_helix_cutter() {
  for (k = [0:thread_steps-1]) {
    t = k/(thread_steps-1);
    z = thread_z0 + t*(thread_z1 - thread_z0);
    ang = 360 * (z / thread_pitch); // one turn per pitch
    translate([0, 0, z])
      rotate([0, 0, ang])
        internal_thread_groove_segment();
  }
}

module insert_solid() {
  union() {
    insert_main_body();
    outer_edge_chamfer_top();
    outer_edge_chamfer_bottom();

    for (i = [0:barb_count-1])
      rotate([0, 0, i*360/barb_count])
        external_barb_tooth();
  }
}

module insert_voids() {
  union() {
    // Clear through-hole (makes the part read as an insert in end views)
    internal_bore_base();

    // Lead-ins and runouts
    thread_lead_in_chamfer_top();
    thread_lead_in_chamfer_bottom();
    bore_relief_runout_top();
    bore_relief_runout_bottom();

    // Internal thread detail (visual approximation)
    internal_thread_helix_cutter();
  }
}

// -------------------- Final Model --------------------
difference() {
  insert_solid();
  insert_voids();
}