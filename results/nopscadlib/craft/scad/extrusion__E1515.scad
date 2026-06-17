// Parameters
profile_width_mm = 15.0; //[7.5:30.0:0.5]
profile_height_mm = 15.0; //[7.5:30.0:0.5]
length_mm = 100.0; //[50.0:200.0:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness_mm = 2.0; //[1.0:4.0:0.25]
slot_opening_mm = 4.0; //[2.0:7.0:0.25]
slot_depth_mm = 4.5; //[2.0:7.0:0.25]
center_bore_d_mm = 5.0; //[2.0:8.0:0.25]
corner_relief_d_mm = 2.5; //[1.0:5.0:0.25]
corner_relief_inset_mm = 3.0; //[1.5:6.0:0.25]
overlap_mm = 1.0; //[0.5:2.0:0.25]

// Extrusion - complete geometry
module extrusion() {
  color("Silver")
  difference() {
    // Main body
    cube([profile_width_mm, profile_height_mm, length_mm], center=true);

    // Center bore
    cylinder(r=center_bore_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=32);

    // T-slot channels
    union() {
      translate([profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
        cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
      translate([-profile_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
        cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
      translate([0, profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
        cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      translate([0, -profile_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
        cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
    }

    // Corner relief holes
    if (cornerHole) {
      union() {
        translate([profile_width_mm/2 - corner_relief_inset_mm, profile_height_mm/2 - corner_relief_inset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
        translate([profile_width_mm/2 - corner_relief_inset_mm, -profile_height_mm/2 + corner_relief_inset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
        translate([-profile_width_mm/2 + corner_relief_inset_mm, profile_height_mm/2 - corner_relief_inset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
        translate([-profile_width_mm/2 + corner_relief_inset_mm, -profile_height_mm/2 + corner_relief_inset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
      }
    }
  }
}

// Extrusion Cross Section - end-cap slice (must be attached)
module extrusion_cross_section() {
  color("DimGray")
    cube([profile_width_mm, profile_height_mm, wall_thickness_mm], center=true);
}

// Box Corner Profile Section - small corner marker (must be attached)
module box_corner_profile_section() {
  color("Black")
    cube([wall_thickness_mm, wall_thickness_mm, wall_thickness_mm], center=true);
}

// Box Corner Profile Sections - place at the 4 corners of the end-cap slice
module box_corner_profile_sections() {
  // Place at corners of the 15x15 end face, not at (-profile_width_mm, ...)
  // Slightly inset so they overlap the end-cap slice by overlap_mm.
  x = profile_width_mm/2 - wall_thickness_mm/2 + overlap_mm;
  y = profile_height_mm/2 - wall_thickness_mm/2 + overlap_mm;

  union() {
    translate([ x,  y, 0]) box_corner_profile_section();
    translate([-x,  y, 0]) box_corner_profile_section();
    translate([ x, -y, 0]) box_corner_profile_section();
    translate([-x, -y, 0]) box_corner_profile_section();
  }
}

// Assembly - ensure EVERYTHING is one connected solid
module assembly() {
  // Attach the end-cap slice and corner markers to the extrusion end with overlap.
  // Extrusion spans z = [-L/2, +L/2]
  // End-cap slice thickness = wall_thickness_mm, centered at:
  // z = -L/2 + wall_thickness_mm/2 - overlap_mm  (push into extrusion by overlap)
  z_endcap = -length_mm/2 + wall_thickness_mm/2 - overlap_mm;

  union() {
    extrusion();

    translate([0, 0, z_endcap])
      extrusion_cross_section();

    translate([0, 0, z_endcap])
      box_corner_profile_sections();
  }
}

assembly();