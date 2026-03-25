// Parameters
profile_width_mm = 40; //[20:80:1]
profile_height_mm = 40; //[20:80:1]
length_mm = 100; //[50:200:1]
center_length = 1; //[0:1:1]
include_corner_holes = 1; //[0:1:1]
wall_thickness_mm = 2.5; //[1.2:5:0.1]
slot_opening_mm = 8.2; //[5:12:0.1]
slot_depth_mm = 10; //[6:16:0.1]
slot_cavity_width_mm = 14; //[10:20:0.1]
slot_cavity_depth_mm = 6; //[3:10:0.1]
center_bore_diameter_mm = 6.8; //[3:12:0.1]
corner_hole_diameter_mm = 4.2; //[0:8:0.1]
corner_hole_offset_mm = 8; //[5:14:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// E4040 Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([profile_width_mm, profile_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + overlap_mm*2], center=true);
        translate([profile_width_mm/2 - slot_depth_mm + slot_cavity_depth_mm/2, 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + overlap_mm*2], center=true);
        translate([-profile_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + overlap_mm*2], center=true);
        translate([-profile_width_mm/2 + slot_depth_mm - slot_cavity_depth_mm/2, 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + overlap_mm*2], center=true);
        translate([0, profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + overlap_mm*2], center=true);
        translate([0, profile_height_mm/2 - slot_depth_mm + slot_cavity_depth_mm/2, 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + overlap_mm*2], center=true);
        translate([0, -profile_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + overlap_mm*2], center=true);
        translate([0, -profile_height_mm/2 + slot_depth_mm - slot_cavity_depth_mm/2, 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + overlap_mm*2], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + overlap_mm*2, center=true);
      
      // Corner holes
      if (include_corner_holes) {
        union() {
          translate([profile_width_mm/2 - corner_hole_offset_mm, profile_height_mm/2 - corner_hole_offset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + overlap_mm*2, center=true);
          translate([-profile_width_mm/2 + corner_hole_offset_mm, profile_height_mm/2 - corner_hole_offset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + overlap_mm*2, center=true);
          translate([-profile_width_mm/2 + corner_hole_offset_mm, -profile_height_mm/2 + corner_hole_offset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + overlap_mm*2, center=true);
          translate([profile_width_mm/2 - corner_hole_offset_mm, -profile_height_mm/2 + corner_hole_offset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + overlap_mm*2, center=true);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  color("DimGray") {
    difference() {
      // Outer profile
      cube([profile_width_mm, profile_height_mm, wall_thickness_mm], center=true);
      
      // Inner cavity
      translate([0, 0, -wall_thickness_mm/2])
        cube([profile_width_mm - 2*wall_thickness_mm, profile_height_mm - 2*wall_thickness_mm, wall_thickness_mm], center=true);
    }
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("Silver") {
    union() {
      // Corner sections
      translate([profile_width_mm/2 - wall_thickness_mm/2, profile_height_mm/2 - wall_thickness_mm/2, 0])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
      translate([-profile_width_mm/2 + wall_thickness_mm/2, profile_height_mm/2 - wall_thickness_mm/2, 0])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
      translate([-profile_width_mm/2 + wall_thickness_mm/2, -profile_height_mm/2 + wall_thickness_mm/2, 0])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
      translate([profile_width_mm/2 - wall_thickness_mm/2, -profile_height_mm/2 + wall_thickness_mm/2, 0])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("Silver") {
    // Single corner section
    translate([profile_width_mm/2 - wall_thickness_mm/2, profile_height_mm/2 - wall_thickness_mm/2, 0])
      cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, 0]) extrusion_cross_section();
  translate([0, 0, 0]) box_corner_profile_sections();
  translate([0, 0, 0]) box_corner_profile_section();
}

assembly();