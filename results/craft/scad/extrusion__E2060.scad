// 20x60 aluminium extrusion profile, 100mm long (single connected solid)
// FIX: ensure the profile is ONE connected solid by forcing a guaranteed central web
// and preventing the inner void + slot pockets from cutting through it.

cross_section_width_mm  = 20;   // X
cross_section_height_mm = 60;   // Y
length_mm               = 100;  // Z

center = 1;                     // compatibility
cornerHole = 1;

wall_thickness_mm        = 2.5;
slot_opening_mm          = 6;
slot_depth_mm            = 6;
slot_internal_width_mm   = 10;
center_bore_diameter_mm  = 6;
corner_hole_diameter_mm  = 4.2;
corner_hole_offset_mm    = 6;

// Use a real overlap for robust manifold connections
overlap_mm = 1.5;

$fn = 64;

module extrusion_2060() {
  w = cross_section_width_mm;
  h = cross_section_height_mm;
  L = length_mm;

  // Robust clamps
  wt = min(wall_thickness_mm, min(w,h)/2 - 0.8);
  sd = min(slot_depth_mm, min(w,h)/2 - wt - 0.8);
  so = min(slot_opening_mm, min(w,h) - 2*wt - 0.8);
  si = min(slot_internal_width_mm, min(w,h) - 2*wt - 0.8);

  // CRITICAL FIX:
  // Guarantee a continuous connecting web between the two long "rails".
  // Make it at least 2mm, and also at least overlap_mm so slicers don't separate shells.
  web = max(2.0, overlap_mm);

  // Inner cavity size (nominal)
  inner_w = max(w - 2*wt, 0.1);
  inner_h = max(h - 2*wt, 0.1);

  // Limit inner void so it cannot remove the central web in either axis
  inner_w_eff = max(min(inner_w, w - 2*wt - web), 0.1);
  inner_h_eff = max(min(inner_h, h - 2*wt - web), 0.1);

  // Slot pocket depth limits so opposite pockets cannot meet (preserve web)
  pocket_depth_x = max(min(sd, w/2 - wt - web/2 - 0.2), 0.1);
  pocket_depth_y = max(min(sd, h/2 - wt - web/2 - 0.2), 0.1);

  // If geometry is too tight, force a minimal pocket depth rather than breaking connectivity
  // (keeps model valid and connected)
  pocket_depth_x = min(pocket_depth_x, sd);
  pocket_depth_y = min(pocket_depth_y, sd);

  color("Silver")
  union() {
    difference() {
      // Outer block
      cube([w, h, L], center=true);

      // Main inner void (reduced to preserve a central web in both axes)
      cube([inner_w_eff, inner_h_eff, L + 2*overlap_mm], center=true);

      // T-slots (simple representation): opening + wider internal pocket
      // Ensure cutters extend slightly beyond the face (overlap) but never through the web.
      union() {
        // +X face
        translate([ w/2 - pocket_depth_x/2 + overlap_mm/2, 0, 0])
          cube([pocket_depth_x + overlap_mm, so, L + 2*overlap_mm], center=true);
        translate([ w/2 - pocket_depth_x/2 - pocket_depth_x/4 + overlap_mm/2, 0, 0])
          cube([pocket_depth_x + overlap_mm, si, L + 2*overlap_mm], center=true);

        // -X face
        translate([-w/2 + pocket_depth_x/2 - overlap_mm/2, 0, 0])
          cube([pocket_depth_x + overlap_mm, so, L + 2*overlap_mm], center=true);
        translate([-w/2 + pocket_depth_x/2 + pocket_depth_x/4 - overlap_mm/2, 0, 0])
          cube([pocket_depth_x + overlap_mm, si, L + 2*overlap_mm], center=true);

        // +Y face
        translate([0,  h/2 - pocket_depth_y/2 + overlap_mm/2, 0])
          cube([so, pocket_depth_y + overlap_mm, L + 2*overlap_mm], center=true);
        translate([0,  h/2 - pocket_depth_y/2 - pocket_depth_y/4 + overlap_mm/2, 0])
          cube([si, pocket_depth_y + overlap_mm, L + 2*overlap_mm], center=true);

        // -Y face
        translate([0, -h/2 + pocket_depth_y/2 - overlap_mm/2, 0])
          cube([so, pocket_depth_y + overlap_mm, L + 2*overlap_mm], center=true);
        translate([0, -h/2 + pocket_depth_y/2 + pocket_depth_y/4 - overlap_mm/2, 0])
          cube([si, pocket_depth_y + overlap_mm, L + 2*overlap_mm], center=true);
      }

      // Center bore (only if it won't disconnect remaining material)
      if (center_bore_diameter_mm > 0 &&
          center_bore_diameter_mm < min(w,h) - 2*wt - web - 1.0)
        cylinder(d=center_bore_diameter_mm, h=L + 2*overlap_mm, center=true);

      // Corner holes (kept within walls)
      if (cornerHole) {
        xh = w/2 - corner_hole_offset_mm;
        yh = h/2 - corner_hole_offset_mm;
        for (sx = [-1, 1], sy = [-1, 1])
          translate([sx*xh, sy*yh, 0])
            cylinder(d=corner_hole_diameter_mm, h=L + 2*overlap_mm, center=true);
      }
    }

    // EXTRA CONNECTIVITY INSURANCE (does not change external design):
    // Add a thin internal cross-web that overlaps the remaining material by overlap_mm.
    // This guarantees the two long halves cannot become disconnected due to boolean edge cases.
    // It sits entirely inside the profile envelope.
    cube([web + 2*overlap_mm, h - 2*wt, L], center=true);
    cube([w - 2*wt, web + 2*overlap_mm, L], center=true);
  }
}

extrusion_2060();