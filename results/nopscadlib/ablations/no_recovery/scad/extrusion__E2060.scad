// Parameters
cross_section_width_mm = 20; //[10:40:1]
cross_section_height_mm = 60; //[30:120:1]
length_mm = 100; //[50:200:1]
center_along_length = 1; //[0:1:1]
include_corner_holes = 1; //[0:1:1]
wall_thickness_mm = 2.2; //[1.2:4.4:0.1]
slot_opening_mm = 6.2; //[4:10:0.1]
slot_depth_mm = 6.5; //[3:12:0.1]
slot_cavity_width_mm = 11.0; //[7:16:0.1]
slot_cavity_depth_mm = 10.0; //[6:16:0.1]
web_thickness_mm = 2.0; //[1.2:4.0:0.1]
center_bore_diameter_mm = 5.2; //[3:10:0.1]
corner_hole_diameter_mm = 4.2; //[2:8:0.1]
corner_hole_inset_mm = 5.5; //[3:11:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Extrusion Cross Section
module extrusion_cross_section() {
  color("Silver") {
    difference() {
      // Main profile
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([cross_section_width_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2, 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-(cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2), 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([-(cross_section_width_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2), 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2, 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -(cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2), 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -(cross_section_height_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2), 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
      
      // Corner holes
      if (include_corner_holes) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-(cross_section_width_mm/2 - corner_hole_inset_mm), cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -(cross_section_height_mm/2 - corner_hole_inset_mm), 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-(cross_section_width_mm/2 - corner_hole_inset_mm), -(cross_section_height_mm/2 - corner_hole_inset_mm), 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section
module box_corner_profile_section() {
  color("DimGray") {
    union() {
      translate([cross_section_width_mm/2 - wall_thickness_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2, 0])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
      translate([-(cross_section_width_mm/2 - wall_thickness_mm/2), cross_section_height_mm/2 - wall_thickness_mm/2, 0])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
      translate([cross_section_width_mm/2 - wall_thickness_mm/2, -(cross_section_height_mm/2 - wall_thickness_mm/2), 0])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
      translate([-(cross_section_width_mm/2 - wall_thickness_mm/2), -(cross_section_height_mm/2 - wall_thickness_mm/2), 0])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
    }
  }
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  color("DimGray") {
    box_corner_profile_section();
  }
}

// Extrusion
module extrusion() {
  color("Silver") {
    translate([0, 0, (1-center_along_length)*length_mm/2])
      extrusion_cross_section();
    box_corner_profile_sections();
  }
}

// Assembly
module assembly() {
  extrusion();
}

assembly();