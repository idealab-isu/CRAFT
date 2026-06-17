// Parameters
cross_section_width_mm = 20; //[10:40:0.5]
cross_section_height_mm = 20; //[10:40:0.5]
length_mm = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
outer_corner_radius_mm = 1; //[0:3:0.25]
wall_thickness_mm = 2; //[1:4:0.25]
slot_opening_width_mm = 6; //[4:10:0.25]
slot_depth_mm = 6; //[4:9:0.25]
slot_cavity_width_mm = 10; //[7:14:0.25]
slot_cavity_depth_mm = 3; //[2:6:0.25]
center_bore_diameter_mm = 5; //[3:10:0.25]
corner_hole_diameter_mm = 3; //[0:6:0.25]
corner_hole_inset_mm = 5; //[3:8:0.25]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([cross_section_width_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2, 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-(cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2), 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-(cross_section_width_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2), 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2, 0])
          cube([slot_opening_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2, 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -(cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2), 0])
          cube([slot_opening_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -(cross_section_height_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2), 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-(cross_section_width_mm/2 - corner_hole_inset_mm), cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-(cross_section_width_mm/2 - corner_hole_inset_mm), -(cross_section_height_mm/2 - corner_hole_inset_mm), 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -(cross_section_height_mm/2 - corner_hole_inset_mm), 0])
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
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([cross_section_width_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2, 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-(cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2), 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([-(cross_section_width_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2), 0, 0])
          cube([slot_cavity_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2, 0])
          cube([slot_opening_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2, 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -(cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2 + overlap_mm/2), 0])
          cube([slot_opening_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -(cross_section_height_mm/2 - slot_depth_mm - (slot_cavity_depth_mm + overlap_mm)/2 + overlap_mm/2), 0])
          cube([slot_cavity_width_mm, slot_cavity_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-(cross_section_width_mm/2 - corner_hole_inset_mm), cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-(cross_section_width_mm/2 - corner_hole_inset_mm), -(cross_section_height_mm/2 - corner_hole_inset_mm), 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -(cross_section_height_mm/2 - corner_hole_inset_mm), 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("Black") {
    cube([(cross_section_width_mm - slot_opening_width_mm)/2, (cross_section_height_mm - slot_opening_width_mm)/2, length_mm], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("Gray") {
    union() {
      translate([cross_section_width_mm/2 - ((cross_section_width_mm - slot_opening_width_mm)/2)/2, cross_section_height_mm/2 - ((cross_section_height_mm - slot_opening_width_mm)/2)/2, 0])
        box_corner_profile_section();
      translate([-(cross_section_width_mm/2 - ((cross_section_width_mm - slot_opening_width_mm)/2)/2), cross_section_height_mm/2 - ((cross_section_height_mm - slot_opening_width_mm)/2)/2, 0])
        box_corner_profile_section();
      translate([cross_section_width_mm/2 - ((cross_section_width_mm - slot_opening_width_mm)/2)/2, -(cross_section_height_mm/2 - ((cross_section_height_mm - slot_opening_width_mm)/2)/2), 0])
        box_corner_profile_section();
      translate([-(cross_section_width_mm/2 - ((cross_section_width_mm - slot_opening_width_mm)/2)/2), -(cross_section_height_mm/2 - ((cross_section_height_mm - slot_opening_width_mm)/2)/2), 0])
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