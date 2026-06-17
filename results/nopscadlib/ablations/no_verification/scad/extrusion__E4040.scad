// Parameters
cross_section_width_mm = 40; //[20:80:1]
cross_section_height_mm = 40; //[20:80:1]
length_mm = 100; //[50:200:1]
wall_thickness_mm = 2.5; //[1.2:5:0.1]
slot_opening_mm = 6; //[3:12:0.5]
slot_depth_mm = 8; //[4:16:0.5]
center_hole_d_mm = 6; //[0:12:0.5]
corner_hole_d_mm = 4.2; //[0:10:0.2]
corner_hole_offset_mm = 8; //[4:16:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      // Slots
      translate([cross_section_width_mm/2 - slot_depth_mm/2 + overlap_mm, 0, 0])
        cube([slot_depth_mm + overlap_mm*2, slot_opening_mm, length_mm + overlap_mm*2], center=true);
      translate([-(cross_section_width_mm/2 - slot_depth_mm/2 + overlap_mm), 0, 0])
        cube([slot_depth_mm + overlap_mm*2, slot_opening_mm, length_mm + overlap_mm*2], center=true);
      translate([0, cross_section_height_mm/2 - slot_depth_mm/2 + overlap_mm, 0])
        cube([slot_opening_mm, slot_depth_mm + overlap_mm*2, length_mm + overlap_mm*2], center=true);
      translate([0, -(cross_section_height_mm/2 - slot_depth_mm/2 + overlap_mm), 0])
        cube([slot_opening_mm, slot_depth_mm + overlap_mm*2, length_mm + overlap_mm*2], center=true);
      // Center hole
      translate([0, 0, 0])
        cylinder(r=center_hole_d_mm/2, h=length_mm + overlap_mm*2, center=true);
      // Corner holes
      translate([cross_section_width_mm/2 - corner_hole_offset_mm, cross_section_height_mm/2 - corner_hole_offset_mm, 0])
        cylinder(r=corner_hole_d_mm/2, h=length_mm + overlap_mm*2, center=true);
      translate([-(cross_section_width_mm/2 - corner_hole_offset_mm), cross_section_height_mm/2 - corner_hole_offset_mm, 0])
        cylinder(r=corner_hole_d_mm/2, h=length_mm + overlap_mm*2, center=true);
      translate([-(cross_section_width_mm/2 - corner_hole_offset_mm), -(cross_section_height_mm/2 - corner_hole_offset_mm), 0])
        cylinder(r=corner_hole_d_mm/2, h=length_mm + overlap_mm*2, center=true);
      translate([cross_section_width_mm/2 - corner_hole_offset_mm, -(cross_section_height_mm/2 - corner_hole_offset_mm), 0])
        cylinder(r=corner_hole_d_mm/2, h=length_mm + overlap_mm*2, center=true);
    }
  }
}

// Box Corner Profile Sections - complete detailed geometry
module box_corner_profile_sections() {
  color("DimGray") {
    // Corner reinforcement blocks
    translate([cross_section_width_mm/2 - wall_thickness_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2, 0])
      cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
    translate([-(cross_section_width_mm/2 - wall_thickness_mm/2), cross_section_height_mm/2 - wall_thickness_mm/2, 0])
      cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
    translate([-(cross_section_width_mm/2 - wall_thickness_mm/2), -(cross_section_height_mm/2 - wall_thickness_mm/2), 0])
      cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
    translate([cross_section_width_mm/2 - wall_thickness_mm/2, -(cross_section_height_mm/2 - wall_thickness_mm/2), 0])
      cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
  }
}

// Assembly
module assembly() {
  extrusion();
  box_corner_profile_sections();
}

assembly();