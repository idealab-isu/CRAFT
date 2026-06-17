// Parameters
cross_section_width_mm = 40; //[20:80:1]
cross_section_height_mm = 80; //[40:160:1]
length_mm = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness_mm = 2.5; //[1.5:5:0.1]
slot_opening_mm = 6; //[4:10:0.5]
slot_depth_mm = 8; //[4:16:0.5]
center_hole_diameter_mm = 8.2; //[4:16:0.1]
corner_hole_diameter_mm = 5.5; //[3:10:0.1]
corner_hole_inset_mm = 10; //[6:16:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Outer body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // Internal voids/channels
      translate([0, 0, 0])
        cube([cross_section_width_mm - 2*wall_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm, length_mm + 2*overlap_mm], center=true);
      
      // Slots
      translate([cross_section_width_mm/2 - slot_depth_mm/2, 0, 0])
        cube([slot_depth_mm + 2*overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
      translate([-(cross_section_width_mm/2 - slot_depth_mm/2), 0, 0])
        cube([slot_depth_mm + 2*overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
      translate([0, cross_section_height_mm/2 - slot_depth_mm/2, 0])
        cube([slot_opening_mm, slot_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);
      translate([0, -(cross_section_height_mm/2 - slot_depth_mm/2), 0])
        cube([slot_opening_mm, slot_depth_mm + 2*overlap_mm, length_mm + 2*overlap_mm], center=true);
      
      // Center hole
      cylinder(h=length_mm + 2*overlap_mm, r=center_hole_diameter_mm/2, center=true);
      
      // Corner holes
      if (cornerHole) {
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(h=length_mm + 2*overlap_mm, r=corner_hole_diameter_mm/2, center=true);
        translate([-(cross_section_width_mm/2 - corner_hole_inset_mm), cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(h=length_mm + 2*overlap_mm, r=corner_hole_diameter_mm/2, center=true);
        translate([-(cross_section_width_mm/2 - corner_hole_inset_mm), -(cross_section_height_mm/2 - corner_hole_inset_mm), 0])
          cylinder(h=length_mm + 2*overlap_mm, r=corner_hole_diameter_mm/2, center=true);
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, -(cross_section_height_mm/2 - corner_hole_inset_mm), 0])
          cylinder(h=length_mm + 2*overlap_mm, r=corner_hole_diameter_mm/2, center=true);
      }
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("DimGray") {
    cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  union() {
    translate([cross_section_width_mm/2 - wall_thickness_mm/2 + overlap_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2 + overlap_mm/2, 0])
      box_corner_profile_section();
    translate([-(cross_section_width_mm/2 - wall_thickness_mm/2 + overlap_mm/2), cross_section_height_mm/2 - wall_thickness_mm/2 + overlap_mm/2, 0])
      box_corner_profile_section();
    translate([-(cross_section_width_mm/2 - wall_thickness_mm/2 + overlap_mm/2), -(cross_section_height_mm/2 - wall_thickness_mm/2 + overlap_mm/2), 0])
      box_corner_profile_section();
    translate([cross_section_width_mm/2 - wall_thickness_mm/2 + overlap_mm/2, -(cross_section_height_mm/2 - wall_thickness_mm/2 + overlap_mm/2), 0])
      box_corner_profile_section();
  }
}

// Assembly
module assembly() {
  extrusion();
  box_corner_profile_sections();
}

assembly();