// Parameters
outer_width_mm = 12; //[6:24:0.5]
outer_height_mm = 8; //[4:16:0.5]
wall_thickness_mm = 1; //[0.5:2:0.1]
length_mm = 100; //[20:400:1]
overlap_mm = 1; //[0.5:2:0.1]
bezel_thickness_mm = 1.5; //[0.8:3:0.1]
bezel_depth_mm = 6; //[2:20:0.5]
corner_profile_leg_mm = 4; //[2:10:0.5]
corner_profile_thickness_mm = 1.5; //[0.8:4:0.1]
shelf_bracket_width_mm = 10; //[5:25:0.5]
shelf_bracket_thickness_mm = 2; //[1:6:0.5]
shelf_bracket_length_mm = 20; //[8:60:1]

// Box Section
module box_section() {
  color("Silver")
  difference() {
    cube([outer_width_mm, outer_height_mm, length_mm], center=true);
    cube([
      outer_width_mm - 2*wall_thickness_mm,
      outer_height_mm - 2*wall_thickness_mm,
      length_mm + 2*overlap_mm
    ], center=true);
  }
}

// Box Bezel Section (overlaps box end by overlap_mm)
module box_bezel_section() {
  bezel_center_z = length_mm/2 - overlap_mm + bezel_depth_mm/2;

  color("DimGray")
  difference() {
    translate([0, 0, bezel_center_z])
      cube([outer_width_mm + 2*bezel_thickness_mm,
            outer_height_mm + 2*bezel_thickness_mm,
            bezel_depth_mm], center=true);

    translate([0, 0, bezel_center_z])
      cube([outer_width_mm + 2*(bezel_thickness_mm - wall_thickness_mm),
            outer_height_mm + 2*(bezel_thickness_mm - wall_thickness_mm),
            bezel_depth_mm + 2*overlap_mm], center=true);
  }
}

// Box Corner Profile Section (intersects box by overlap_mm in X and Y)
module box_corner_profile_section() {
  color("Black")
  union() {
    // Horizontal leg along +X, near +Y edge
    translate([outer_width_mm/2 + corner_profile_leg_mm/2 - overlap_mm,
               outer_height_mm/2 - corner_profile_thickness_mm/2,
               0])
      cube([corner_profile_leg_mm, corner_profile_thickness_mm, length_mm], center=true);

    // Vertical leg along +Y, near +X edge
    translate([outer_width_mm/2 - corner_profile_thickness_mm/2,
               outer_height_mm/2 + corner_profile_leg_mm/2 - overlap_mm,
               0])
      cube([corner_profile_thickness_mm, corner_profile_leg_mm, length_mm], center=true);
  }
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  union() {
    box_section();
    box_corner_profile_section();
  }
}

// Box Shelf Bracket Section
module box_shelf_bracket_section() {
  // Attach bracket to the +X side and to the -Z end with overlap in BOTH axes.
  // X: bracket min_x = outer_width/2 - overlap_mm
  bracket_center_x = outer_width_mm/2 - overlap_mm + shelf_bracket_length_mm/2;

  // Z: bracket max_z = -length/2 + overlap_mm
  // => center_z + thickness/2 = -length/2 + overlap_mm
  bracket_center_z = -length_mm/2 + overlap_mm - shelf_bracket_thickness_mm/2;

  // --- FIX: add a small "tab" that was previously floating/offset ---
  // Place it at the -Z end and on the +X side, and make it overlap the box by overlap_mm.
  // This guarantees it is physically connected (no gap) and merges in union().
  tab_len_x = 3;                         // small protruding length
  tab_w_y   = corner_profile_thickness_mm; // keep it small like the corner profile thickness
  tab_h_z   = 2;                         // small height at the end
  tab_center_x = outer_width_mm/2 - overlap_mm + tab_len_x/2; // overlaps box in X by overlap_mm
  tab_center_y = 0;
  tab_center_z = -length_mm/2 + tab_h_z/2 - overlap_mm;       // overlaps box end in Z by overlap_mm

  color("Silver")
  union() {
    box_corner_profile_sections();

    // Shelf bracket (main protruding feature)
    translate([bracket_center_x, 0, bracket_center_z])
      cube([shelf_bracket_length_mm, shelf_bracket_width_mm, shelf_bracket_thickness_mm], center=true);

    // Small tab/feature (now attached with deliberate overlap)
    translate([tab_center_x, tab_center_y, tab_center_z])
      cube([tab_len_x, tab_w_y, tab_h_z], center=true);
  }
}

// Assembly (single connected solid via union; all parts overlap)
module assembly() {
  union() {
    box_shelf_bracket_section();
    box_bezel_section();
  }
}

assembly();