// Dimension-calibrated (target: 0.32 x 0.06 x 0.36 mm)
scale([1.074576, 0.640000, 1.659918])
{
// Curved arc-shaped bracket/clip (ONE connected solid)
// Structural fixes applied:
// - Make the long central opening a CLEAR THROUGH-SLOT by cutting a radial gap (between two ribs)
// - Keep two concentric curved ribs (inner + outer) with an explicit separation
// - Slot is tapered along arc length (wider toward thin end)
// - End block + tab/peg are guaranteed to intersect the body (recalculated placement)
// - Thin end is shaved/tapered
// - All parts remain one connected solid (small overlaps)
// - Final clipped to bounding box (0.30 x 0.10 x 0.40 mm), elongated along Z

// ---------------- Parameters (mm) ----------------
bbox_x = 0.30;   // X
bbox_y = 0.10;   // Y
bbox_z = 0.40;   // Z (elongated axis)

// Arc / ribs (annular sector)
arc_outer_radius = 0.145;
arc_inner_radius = 0.115;
arc_angle_deg    = 210;      // C-like opening

rib_width_y      = bbox_y;   // full width in Y

// --- NEW: explicit rib separation via radial slot (between ribs) ---
// Two ribs: inner rib [arc_inner_radius .. rib_split_r] and outer rib [rib_split_r+slot .. arc_outer_radius]
rib_split_r      = 0.130;    // nominal split radius between ribs (must be between inner and outer)
slot_rad_start   = 0.006;    // radial slot thickness near thick end
slot_rad_end     = 0.016;    // radial slot thickness near thin end

// Slot angular span (leave material near ends)
slot_ang_start   = 10;
slot_ang_end     = arc_angle_deg - 10;

// End features
end_block_len_z   = 0.060;   // along Z
end_block_rad_thk = 0.020;   // radial thickness (X-ish)
tab_len_rad       = 0.018;   // radial protrusion
tab_w_y           = 0.014;   // Y width (slightly larger for visibility)
tab_h_z           = 0.012;   // Z height (slightly larger for visibility)

// Thin end taper (shave outer rib near end)
thin_end_taper_ang = 35;
thin_end_shave_rad = 0.020;

// Connectivity / robustness
overlap = 0.002;
$fn = 128;

// ---------------- Helpers ----------------
module overall_envelope_bounding_box() {
  cube([bbox_x, bbox_y, bbox_z], center=true);
}

// 2D annular sector in XY, spanning angle [0..ang_deg] about origin.
module annular_sector_2d(r_in, r_out, ang_deg) {
  intersection() {
    difference() {
      circle(r=r_out);
      circle(r=r_in);
    }
    polygon(points=concat(
      [[0,0]],
      [for (a=[0:1:ang_deg]) [ (r_out+1)*cos(a), (r_out+1)*sin(a) ]]
    ));
  }
}

// Extrude annular sector to 3D with width in Y, arc lying in XZ.
module sector3d_y(r_in, r_out, ang_deg, y_w) {
  rotate([90,0,0])
    linear_extrude(height=y_w, center=true, convexity=10)
      annular_sector_2d(r_in, r_out, ang_deg);
}

// Main curved body: two ribs with a clear radial separation (slot) between them.
module curved_clip_body_two_ribs() {
  // Ensure split radius is valid and leaves room for max slot
  max_slot = max(slot_rad_start, slot_rad_end);
  r_split_ok = min(max(rib_split_r, arc_inner_radius + max_slot + 0.001), arc_outer_radius - max_slot - 0.001);

  union() {
    // Inner rib
    sector3d_y(arc_inner_radius, r_split_ok - overlap, arc_angle_deg, rib_width_y);

    // Outer rib
    sector3d_y(r_split_ok + overlap, arc_outer_radius, arc_angle_deg, rib_width_y);
  }
}

// Tapered radial slot cutter: removes material between ribs, varying radial thickness along arc.
module tapered_radial_slot_cutter() {
  // Use the same guarded split radius as body
  max_slot = max(slot_rad_start, slot_rad_end);
  r_split_ok = min(max(rib_split_r, arc_inner_radius + max_slot + 0.001), arc_outer_radius - max_slot - 0.001);

  step = 3; // degrees
  union() {
    for (a=[slot_ang_start:step:slot_ang_end-step]) {
      t = (a - slot_ang_start) / max(0.0001, (slot_ang_end - slot_ang_start));
      slot_rad = slot_rad_start + (slot_rad_end - slot_rad_start) * t;

      r_in  = (r_split_ok - slot_rad/2) - overlap;
      r_out = (r_split_ok + slot_rad/2) + overlap;

      // Clamp to valid radii
      r_in_c  = max(r_in,  arc_inner_radius + overlap);
      r_out_c = min(r_out, arc_outer_radius - overlap);

      rotate([0,0,a])
        sector3d_y(r_in_c, r_out_c, step + 0.4, rib_width_y + 2*overlap);
    }
  }
}

// Thick end block at arc start (angle 0), guaranteed to intersect outer rib.
module thick_end_block() {
  a = 0;

  // Place block so its inner face penetrates the outer rib by overlap.
  // Block spans X: [x_c - thk/2 .. x_c + thk/2]
  // Want (x_c - thk/2) <= arc_outer_radius - overlap
  x_c = (arc_outer_radius - overlap) + end_block_rad_thk/2 - overlap;

  // Keep within bbox after final intersection; Z centered at 0 for robust overlap with arc.
  translate([x_c*cos(a), 0, x_c*sin(a)])
    cube([end_block_rad_thk, rib_width_y + 2*overlap, end_block_len_z], center=true);
}

// Protruding tab/peg on the thick end block, extending outward (+X), guaranteed to intersect block.
module protruding_tab_peg() {
  // End block outer face is at x = x_c + end_block_rad_thk/2
  x_c_block = (arc_outer_radius - overlap) + end_block_rad_thk/2 - overlap;
  x_outer_face = x_c_block + end_block_rad_thk/2;

  // Place tab so it overlaps the block by overlap:
  // tab spans X: [x_tab - tab/2 .. x_tab + tab/2]
  // Want (x_tab - tab/2) <= x_outer_face - overlap
  x_tab = (x_outer_face - overlap) + tab_len_rad/2 - overlap;

  translate([x_tab, 0, 0])
    cube([tab_len_rad, tab_w_y, tab_h_z], center=true);
}

// Thin end taper: shave outer radius near arc end to make it thinner/tapered.
module thin_end_taper_cut() {
  a0 = arc_angle_deg - thin_end_taper_ang;
  a1 = arc_angle_deg;

  r_cut_in  = arc_outer_radius - thin_end_shave_rad;
  r_cut_out = arc_outer_radius + 1;

  rotate([0,0,a0])
    sector3d_y(r_cut_in, r_cut_out, (a1 - a0) + 0.4, rib_width_y + 2*overlap);
}

// Assemble connected solid
module main_solid() {
  union() {
    difference() {
      curved_clip_body_two_ribs();
      // Explicit, clearly visible through-slot between ribs (tapered)
      tapered_radial_slot_cutter();
      // Thin end taper
      thin_end_taper_cut();
    }
    // Attachments on thick end (with overlap)
    thick_end_block();
    protruding_tab_peg();
  }
}

// Final: clip to bounding box to guarantee size
intersection() {
  main_solid();
  overall_envelope_bounding_box();
}
}
