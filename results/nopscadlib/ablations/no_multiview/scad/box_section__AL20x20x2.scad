// Parameters
outer_width_mm = 20; //[10:40:1]
outer_height_mm = 20; //[10:40:1]
wall_thickness_mm = 2; //[1:6:0.5]
length_mm = 100; //[20:400:1]
overlap_mm = 1; //[0.5:2:0.5]

// Box Section - Primary Component (hollow rectangular tube)
module box_section() {
  difference() {
    // Outer box
    cube([outer_width_mm, outer_height_mm, length_mm], center=true);

    // Inner void (slightly longer to avoid coplanar faces)
    cube([outer_width_mm - 2*wall_thickness_mm,
          outer_height_mm - 2*wall_thickness_mm,
          length_mm + 2*overlap_mm], center=true);
  }
}

// Long parallel side walls/strips that must be ATTACHED to the main body.
// These are placed on the +Y and -Y outer faces and overlap into the tube by overlap_mm.
module attached_side_strips() {
  strip_thick = wall_thickness_mm;                 // thickness in Y
  strip_width = wall_thickness_mm;                 // width in X (kept small like a "strip")
  strip_len   = length_mm + 2*overlap_mm;          // ensure overlap at ends too

  // Position so each strip intersects the outer wall by overlap_mm (no gap).
  y_pos = outer_height_mm/2 - strip_thick/2 + overlap_mm;

  // Two long parallel strips (top view shows them as two long lines)
  translate([0,  y_pos, 0])
    cube([strip_width, strip_thick, strip_len], center=true);

  translate([0, -y_pos, 0])
    cube([strip_width, strip_thick, strip_len], center=true);
}

// Box Corner Profile Section - Secondary Component (ensure it intersects the tube)
module box_corner_profile_section() {
  // Put it on the outside corner but overlap into the tube by overlap_mm
  x0 = -outer_width_mm/2 - overlap_mm;
  y0 = -outer_height_mm/2 - overlap_mm;

  translate([x0, y0, -length_mm/2 - overlap_mm])
    cube([wall_thickness_mm + overlap_mm,
          wall_thickness_mm + overlap_mm,
          length_mm + 2*overlap_mm], center=false);
}

// Box Bezel Section - Secondary Component (ensure it intersects the tube end)
module box_bezel_section() {
  // Place at +Z end and overlap into the tube by overlap_mm
  z0 = length_mm/2 - overlap_mm;

  translate([-outer_width_mm/2 - overlap_mm,
             -outer_height_mm/2 - overlap_mm,
              z0])
    cube([outer_width_mm + 2*overlap_mm,
          wall_thickness_mm + overlap_mm,
          wall_thickness_mm + overlap_mm], center=false);
}

// Box Corner Profile Sections - Secondary Component (ensure they intersect the tube)
module box_corner_profile_sections() {
  // Two additional corner blocks, each overlapping into the tube by overlap_mm
  z0 = -length_mm/2 - overlap_mm;

  // Near (+X, -Y) corner
  translate([ outer_width_mm/2 - wall_thickness_mm - overlap_mm,
            -outer_height_mm/2 - overlap_mm,
             z0])
    cube([wall_thickness_mm + overlap_mm,
          wall_thickness_mm + overlap_mm,
          length_mm + 2*overlap_mm], center=false);

  // Near (-X, +Y) corner
  translate([-outer_width_mm/2 - overlap_mm,
              outer_height_mm/2 - wall_thickness_mm - overlap_mm,
              z0])
    cube([wall_thickness_mm + overlap_mm,
          wall_thickness_mm + overlap_mm,
          length_mm + 2*overlap_mm], center=false);
}

// Box Shelf Bracket Section - Secondary Component (ensure it intersects the tube)
module box_shelf_bracket_section() {
  // Keep original idea but attach by overlapping into the tube at the -Z end
  bracket_h = 10;
  z0 = -length_mm/2 - overlap_mm; // overlap into tube end

  difference() {
    union() {
      // Vertical plate (along X, thin in Y)
      translate([-outer_width_mm/2 - overlap_mm,
                 -outer_height_mm/2 - overlap_mm,
                  z0])
        cube([outer_width_mm + 2*overlap_mm,
              wall_thickness_mm + overlap_mm,
              bracket_h + overlap_mm], center=false);

      // Horizontal plate (along Y, thin in X)
      translate([-outer_width_mm/2 - overlap_mm,
                 -outer_height_mm/2 - overlap_mm,
                  z0])
        cube([wall_thickness_mm + overlap_mm,
              outer_height_mm + 2*overlap_mm,
              bracket_h + overlap_mm], center=false);
    }

    // Mounting holes (kept as-is, centered in the bracket volume)
    translate([-outer_width_mm/4, -outer_height_mm/4, -length_mm/2 + bracket_h/2])
      cylinder(r=1.5, h=bracket_h + 2*overlap_mm, center=true, $fn=16);

    translate([ outer_width_mm/4,  outer_height_mm/4, -length_mm/2 + bracket_h/2])
      cylinder(r=1.5, h=bracket_h + 2*overlap_mm, center=true, $fn=16);
  }
}

// Assembly (single connected solid)
module assembly() {
  union() {
    box_section();

    // FIX: attach the two long parallel strips to the main body with overlap
    attached_side_strips();

    // Other secondary components, adjusted to overlap/intersect the main body
    box_corner_profile_section();
    box_bezel_section();
    box_corner_profile_sections();
    box_shelf_bracket_section();
  }
}

assembly();