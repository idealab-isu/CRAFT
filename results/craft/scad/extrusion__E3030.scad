// Parameters
profile_width_mm = 30; //[15:60:1]
profile_height_mm = 30; //[15:60:1]
length_mm = 100; //[50:200:1]
wall_thickness_mm = 2.2; //[1.1:4.4:0.1]
slot_opening_mm = 6.2; //[3.1:12.4:0.1]
slot_depth_mm = 7.5; //[3.5:14:0.1]
slot_cavity_width_mm = 12.0; //[6:24:0.1]
center_bore_d_mm = 8.2; //[4:16:0.1]
web_thickness_mm = 2.4; //[1.2:5:0.1]
corner_relief_d_mm = 4.0; //[2:8:0.1]
corner_relief_offset_mm = 6.0; //[3:12:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// E3030 - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main extrusion body
      cube([profile_width_mm, profile_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2 - wall_thickness_mm/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-profile_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([-profile_width_mm/2 + (slot_depth_mm + overlap_mm)/2 + wall_thickness_mm/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2 - wall_thickness_mm/2, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -profile_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -profile_height_mm/2 + (slot_depth_mm + overlap_mm)/2 + wall_thickness_mm/2, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
      
      // Corner reliefs
      union() {
        translate([profile_width_mm/2 - corner_relief_offset_mm, profile_height_mm/2 - corner_relief_offset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
        translate([-profile_width_mm/2 + corner_relief_offset_mm, profile_height_mm/2 - corner_relief_offset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
        translate([-profile_width_mm/2 + corner_relief_offset_mm, -profile_height_mm/2 + corner_relief_offset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
        translate([profile_width_mm/2 - corner_relief_offset_mm, -profile_height_mm/2 + corner_relief_offset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  color("DimGray") {
    difference() {
      // Main extrusion body
      cube([profile_width_mm, profile_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2 - wall_thickness_mm/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-profile_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([-profile_width_mm/2 + (slot_depth_mm + overlap_mm)/2 + wall_thickness_mm/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2 - wall_thickness_mm/2, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -profile_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -profile_height_mm/2 + (slot_depth_mm + overlap_mm)/2 + wall_thickness_mm/2, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
      
      // Corner reliefs
      union() {
        translate([profile_width_mm/2 - corner_relief_offset_mm, profile_height_mm/2 - corner_relief_offset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
        translate([-profile_width_mm/2 + corner_relief_offset_mm, profile_height_mm/2 - corner_relief_offset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
        translate([-profile_width_mm/2 + corner_relief_offset_mm, -profile_height_mm/2 + corner_relief_offset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
        translate([profile_width_mm/2 - corner_relief_offset_mm, -profile_height_mm/2 + corner_relief_offset_mm, 0])
          cylinder(r=corner_relief_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("Silver") {
    union() {
      box_corner_profile_section();
      rotate([0, 0, 90]) box_corner_profile_section();
      rotate([0, 0, 180]) box_corner_profile_section();
      rotate([0, 0, 270]) box_corner_profile_section();
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("Silver") {
    translate([profile_width_mm/2 - wall_thickness_mm/2, profile_height_mm/2 - wall_thickness_mm/2, 0])
      cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, 0]) extrusion_cross_section();
  translate([0, 0, 0]) box_corner_profile_sections();
}

assembly();