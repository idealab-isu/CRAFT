// Parameters
cross_section_width_mm = 30; //[15:60:1]
cross_section_height_mm = 60; //[30:120:1]
length_mm = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
wall_thickness_mm = 2.5; //[1.5:5:0.1]
slot_opening_width_mm = 6; //[4:10:0.1]
slot_cavity_width_mm = 12; //[8:18:0.1]
slot_depth_mm = 8; //[5:14:0.1]
slot_opening_depth_mm = 2.5; //[1.5:5:0.1]
center_bore_diameter_mm = 8; //[4:16:0.1]
web_thickness_mm = 3; //[2:6:0.1]
corner_hole_diameter_mm = 4; //[0:8:0.1]
corner_hole_offset_from_edges_mm = 7.5; //[4:15:0.1]

// E3060 - Detailed geometry for T-slot extrusion
module extrusion() {
  color("Silver") {
    difference() {
      // Outer body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        // Right T-slot
        translate([cross_section_width_mm/2 - (slot_opening_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_opening_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([cross_section_width_mm/2 - slot_opening_depth_mm - (slot_depth_mm + overlap_mm)/2 + overlap_mm, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        
        // Left T-slot
        translate([-cross_section_width_mm/2 + (slot_opening_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_opening_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-cross_section_width_mm/2 + slot_opening_depth_mm + (slot_depth_mm + overlap_mm)/2 - overlap_mm, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        
        // Top T-slot
        translate([0, cross_section_height_mm/2 - (slot_opening_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_width_mm, slot_opening_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - slot_opening_depth_mm - (slot_depth_mm + overlap_mm)/2 + overlap_mm, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        
        // Bottom T-slot
        translate([0, -cross_section_height_mm/2 + (slot_opening_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_width_mm, slot_opening_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -cross_section_height_mm/2 + slot_opening_depth_mm + (slot_depth_mm + overlap_mm)/2 - overlap_mm, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
      
      // Internal webbing
      union() {
        translate([0, 0, 0])
          cube([cross_section_width_mm - 2*wall_thickness_mm, web_thickness_mm, length_mm], center=true);
        translate([0, 0, 0])
          cube([web_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm, length_mm], center=true);
      }
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_offset_from_edges_mm, cross_section_height_mm/2 - corner_hole_offset_from_edges_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_offset_from_edges_mm, cross_section_height_mm/2 - corner_hole_offset_from_edges_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_offset_from_edges_mm, -cross_section_height_mm/2 + corner_hole_offset_from_edges_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_offset_from_edges_mm, -cross_section_height_mm/2 + corner_hole_offset_from_edges_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - Detailed geometry
module box_corner_profile_section() {
  color("DimGray") {
    cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
  }
}

// Box Corner Profile Sections - Detailed geometry
module box_corner_profile_sections() {
  union() {
    translate([cross_section_width_mm/2 - wall_thickness_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2, 0])
      box_corner_profile_section();
    translate([-cross_section_width_mm/2 + wall_thickness_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2, 0])
      box_corner_profile_section();
    translate([cross_section_width_mm/2 - wall_thickness_mm/2, -cross_section_height_mm/2 + wall_thickness_mm/2, 0])
      box_corner_profile_section();
    translate([-cross_section_width_mm/2 + wall_thickness_mm/2, -cross_section_height_mm/2 + wall_thickness_mm/2, 0])
      box_corner_profile_section();
  }
}

// Extrusion Cross Section - Detailed geometry
module extrusion_cross_section() {
  difference() {
    extrusion();
    box_corner_profile_sections();
  }
}

// Assembly - Combine all parts
module assembly() {
  extrusion_cross_section();
}

assembly();