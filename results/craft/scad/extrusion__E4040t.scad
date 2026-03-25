// Parameters
cross_section_width_mm = 40; //[20:80:1]
cross_section_height_mm = 40; //[20:80:1]
length_mm = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
outer_wall_mm = 2.5; //[1.5:5:0.1]
slot_opening_mm = 8; //[5:12:0.5]
slot_depth_mm = 10; //[6:16:0.5]
slot_cavity_width_mm = 14; //[10:20:0.5]
slot_cavity_depth_mm = 6; //[3:10:0.5]
center_bore_d_mm = 6.8; //[4:12:0.1]
corner_hole_d_mm = 4.2; //[2:8:0.1]
corner_hole_offset_mm = 10; //[6:16:0.5]
corner_feature_size_mm = 6; //[3:12:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// E4040 Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=32);
      
      // T-slot channels
      union() {
        // X-axis slots
        translate([cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([cross_section_width_mm/2 - slot_depth_mm + (slot_cavity_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-(cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2), 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([-(cross_section_width_mm/2 - slot_depth_mm + (slot_cavity_depth_mm + overlap_mm)/2), 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        
        // Y-axis slots
        translate([0, cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - slot_depth_mm + (slot_cavity_depth_mm + overlap_mm)/2, 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -(cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2), 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -(cross_section_height_mm/2 - slot_depth_mm + (slot_cavity_depth_mm + overlap_mm)/2), 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_offset_mm, cross_section_height_mm/2 - corner_hole_offset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
          translate([cross_section_width_mm/2 - corner_hole_offset_mm, -(cross_section_height_mm/2 - corner_hole_offset_mm), 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
          translate([-(cross_section_width_mm/2 - corner_hole_offset_mm), cross_section_height_mm/2 - corner_hole_offset_mm, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
          translate([-(cross_section_width_mm/2 - corner_hole_offset_mm), -(cross_section_height_mm/2 - corner_hole_offset_mm), 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
        }
      }
    }
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("DimGray") {
    union() {
      box_corner_profile_section([cross_section_width_mm/2 - corner_feature_size_mm/2 - overlap_mm, cross_section_height_mm/2 - corner_feature_size_mm/2 - overlap_mm, 0]);
      box_corner_profile_section([cross_section_width_mm/2 - corner_feature_size_mm/2 - overlap_mm, -(cross_section_height_mm/2 - corner_feature_size_mm/2 - overlap_mm), 0]);
      box_corner_profile_section([-(cross_section_width_mm/2 - corner_feature_size_mm/2 - overlap_mm), cross_section_height_mm/2 - corner_feature_size_mm/2 - overlap_mm, 0]);
      box_corner_profile_section([-(cross_section_width_mm/2 - corner_feature_size_mm/2 - overlap_mm), -(cross_section_height_mm/2 - corner_feature_size_mm/2 - overlap_mm), 0]);
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section(position) {
  translate(position)
    cube([corner_feature_size_mm, corner_feature_size_mm, length_mm], center=true);
}

// Assembly
module assembly() {
  extrusion();
  box_corner_profile_sections();
}

assembly();