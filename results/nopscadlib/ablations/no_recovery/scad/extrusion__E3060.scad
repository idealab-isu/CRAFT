// Parameters
cross_section_width_mm = 30; //[15:60:1]
cross_section_height_mm = 60; //[30:120:1]
length_mm = 100; //[50:200:1]
wall_thickness_mm = 2.5; //[1.2:5:0.1]
slot_opening_width_mm = 6.2; //[4:10:0.1]
slot_cavity_width_mm = 12; //[8:18:0.1]
slot_depth_mm = 8; //[5:14:0.1]
slot_opening_depth_mm = 3; //[1.5:6:0.1]
center_bore_diameter_mm = 8.2; //[4:16:0.1]
web_thickness_mm = 2.2; //[1.2:5:0.1]
corner_hole_diameter_mm = 4.2; //[2:8:0.1]
corner_hole_inset_mm = 7.5; //[4:15:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Outer body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        // X positive
        translate([cross_section_width_mm/2 - (slot_opening_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_opening_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        
        // X negative
        translate([-cross_section_width_mm/2 + (slot_opening_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_opening_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-cross_section_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        
        // Y positive
        translate([0, cross_section_height_mm/2 - (slot_opening_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_width_mm, slot_opening_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        
        // Y negative
        translate([0, -cross_section_height_mm/2 + (slot_opening_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_width_mm, slot_opening_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -cross_section_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore and internal webbing
      union() {
        // Center bore
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
        
        // Internal voids
        cube([cross_section_width_mm - 2*wall_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm - 2*web_thickness_mm, length_mm + 2*overlap_mm], center=true);
        cube([cross_section_width_mm - 2*wall_thickness_mm - 2*web_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  color("DimGray") {
    difference() {
      // Outer body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        // X positive
        translate([cross_section_width_mm/2 - (slot_opening_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_opening_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        
        // X negative
        translate([-cross_section_width_mm/2 + (slot_opening_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_opening_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-cross_section_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        
        // Y positive
        translate([0, cross_section_height_mm/2 - (slot_opening_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_width_mm, slot_opening_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        
        // Y negative
        translate([0, -cross_section_height_mm/2 + (slot_opening_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_width_mm, slot_opening_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -cross_section_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore and internal webbing
      union() {
        // Center bore
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
        
        // Internal voids
        cube([cross_section_width_mm - 2*wall_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm - 2*web_thickness_mm, length_mm + 2*overlap_mm], center=true);
        cube([cross_section_width_mm - 2*wall_thickness_mm - 2*web_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("Black") {
    cube([wall_thickness_mm + overlap_mm, wall_thickness_mm + overlap_mm, length_mm], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("Black") {
    union() {
      box_corner_profile_section();
      translate([-cross_section_width_mm + wall_thickness_mm + overlap_mm, 0, 0])
        box_corner_profile_section();
      translate([0, -cross_section_height_mm + wall_thickness_mm + overlap_mm, 0])
        box_corner_profile_section();
      translate([-cross_section_width_mm + wall_thickness_mm + overlap_mm, -cross_section_height_mm + wall_thickness_mm + overlap_mm, 0])
        box_corner_profile_section();
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  extrusion_cross_section();
  box_corner_profile_sections();
}

assembly();