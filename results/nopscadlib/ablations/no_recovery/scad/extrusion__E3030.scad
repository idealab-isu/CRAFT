// Parameters
cross_section_width_mm = 30; //[15:60:0.5]
cross_section_height_mm = 30; //[15:60:0.5]
length_mm = 100; //[50:200:1]
center_length = 1; //[0:1:1]
include_corner_holes = 1; //[0:1:1]
wall_thickness_mm = 2.2; //[1.2:4.4:0.1]
slot_opening_width_mm = 8.2; //[5:12:0.1]
slot_depth_mm = 7.5; //[4:12:0.1]
slot_inner_width_mm = 12.0; //[8:18:0.1]
center_bore_diameter_mm = 8.4; //[4:14:0.1]
web_thickness_mm = 2.0; //[1.2:4.0:0.1]
corner_hole_diameter_mm = 4.2; //[2.5:7:0.1]
corner_hole_inset_mm = 6.5; //[4:10:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width_mm/2 - slot_depth_mm/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-cross_section_width_mm/2 + slot_depth_mm/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - slot_depth_mm/2, 0])
          cube([slot_opening_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -cross_section_height_mm/2 + slot_depth_mm/2, 0])
          cube([slot_opening_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=32);
    }
  }
}

// Extrusion Cross Section - complete detailed geometry
module extrusion_cross_section() {
  color("DimGray") {
    difference() {
      // Cross section
      cube([cross_section_width_mm, cross_section_height_mm, web_thickness_mm], center=true);
      
      // Internal webs
      union() {
        translate([0, 0, 0])
          cube([cross_section_width_mm - 2*wall_thickness_mm, web_thickness_mm, length_mm], center=true);
        translate([0, 0, 0])
          cube([web_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm, length_mm], center=true);
      }
    }
  }
}

// Box Corner Profile Section - complete detailed geometry
module box_corner_profile_section() {
  color("Black") {
    cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
  }
}

// Box Corner Profile Sections - complete detailed geometry
module box_corner_profile_sections() {
  color("Black") {
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
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, length_mm/2 + web_thickness_mm/2]) extrusion_cross_section();
  box_corner_profile_sections();
}

assembly();