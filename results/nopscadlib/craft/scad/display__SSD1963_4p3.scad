// LCD display 4.3" — 105.5 x 67.2 x 3.4
// One connected solid (union), no floating parts.

// --- Primary dimensions (match request) ---
overall_width_mm     = 105.5;
overall_height_mm    = 67.2;
overall_thickness_mm = 3.4;

// Front aperture (window recess) from spec points
aperture_min_x_mm = -50;
aperture_min_y_mm = -26.5;
aperture_max_x_mm =  50;
aperture_max_y_mm =  31.5;
aperture_depth_mm = 0.5;

// FFC tail placement points: [[0, -34.5], [12, -31.5]]
ffc_x0 = 0;
ffc_y0 = -34.5;
ffc_x1 = 12;
ffc_y1 = -31.5;

// Tail geometry (kept modest; must be connected)
tail_thickness_mm = 0.8;
tail_len_mm       = 12;

// Back-side bosses (keep single connected solid)
mounting_hole_diameter_mm   = 2.6;
mounting_hole_edge_margin_mm = 5;
boss_h_mm        = 0.8;
boss_overlap_mm  = 0.25;

eps_mm     = 0.05;
overlap_mm = 0.3;

module lcd_display_solid() {
  union() {
    // Base body with front aperture recess (difference yields one solid)
    difference() {
      cube([overall_width_mm, overall_height_mm, overall_thickness_mm], center=true);

      // Aperture recess from the front face (+Z)
      translate([
        (aperture_min_x_mm + aperture_max_x_mm)/2,
        (aperture_min_y_mm + aperture_max_y_mm)/2,
        overall_thickness_mm/2 - (aperture_depth_mm + eps_mm)/2
      ])
        cube([
          (aperture_max_x_mm - aperture_min_x_mm),
          (aperture_max_y_mm - aperture_min_y_mm),
          aperture_depth_mm + eps_mm
        ], center=true);
    }

    // FFC tail: use given XY points for width and center; attach to bottom edge (negative Y)
    tail_w = abs(ffc_x1 - ffc_x0);

    // Ensure non-zero width
    tail_w_eff = max(tail_w, 0.1);

    // Attach so tail overlaps into body by overlap_mm at y = -overall_height/2
    translate([
      (ffc_x0 + ffc_x1)/2,
      -overall_height_mm/2 - tail_len_mm/2 + overlap_mm/2,
      0  // centered in thickness so it is visible in side/top views
    ])
      cube([tail_w_eff, tail_len_mm, tail_thickness_mm], center=true);

    // Back-side bosses at 4 corners (connected via overlap)
    for (x_mult = [-1, 1], y_mult = [-1, 1]) {
      translate([
        x_mult * (overall_width_mm/2 - mounting_hole_edge_margin_mm),
        y_mult * (overall_height_mm/2 - mounting_hole_edge_margin_mm),
        -overall_thickness_mm/2 - boss_h_mm/2 + boss_overlap_mm/2
      ])
        cylinder(
          r = mounting_hole_diameter_mm/2,
          h = boss_h_mm + boss_overlap_mm,
          center = true,
          $fn = 32
        );
    }
  }
}

// --- Assembly (single connected solid) ---
lcd_display_solid();