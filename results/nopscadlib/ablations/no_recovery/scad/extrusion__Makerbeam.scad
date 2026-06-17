// Parameters
cross_section_width_mm = 10; //[5:20:0.5]
cross_section_height_mm = 10; //[5:20:0.5]
length_mm = 100; //[50:200:1]
centered = 1; //[0:1:1]
corner_hole = 1; //[0:1:1]
wall_thickness_mm = 1.2; //[0.6:2.4:0.1]
slot_opening_mm = 3.0; //[1.5:5.0:0.1]
slot_depth_mm = 2.8; //[1.5:4.5:0.1]
center_bore_diameter_mm = 4.2; //[2.0:7.0:0.1]
corner_hole_diameter_mm = 2.2; //[1.0:4.0:0.1]
corner_hole_inset_mm = 2.5; //[1.5:4.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([-cross_section_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -cross_section_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
      
      // Corner holes
      if (corner_hole) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  color("DimGray") {
    cube([cross_section_width_mm, cross_section_height_mm, wall_thickness_mm], center=true);
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("DimGray") {
    cube([cross_section_width_mm/2 - wall_thickness_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2, wall_thickness_mm], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("DimGray") {
    union() {
      translate([cross_section_width_mm/4, cross_section_height_mm/4, length_mm/2 - wall_thickness_mm/2])
        box_corner_profile_section();
      translate([-cross_section_width_mm/4, cross_section_height_mm/4, length_mm/2 - wall_thickness_mm/2])
        box_corner_profile_section();
      translate([cross_section_width_mm/4, -cross_section_height_mm/4, length_mm/2 - wall_thickness_mm/2])
        box_corner_profile_section();
      translate([-cross_section_width_mm/4, -cross_section_height_mm/4, length_mm/2 - wall_thickness_mm/2])
        box_corner_profile_section();
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, length_mm/2 - wall_thickness_mm/2]) extrusion_cross_section();
  box_corner_profile_sections();
}

assembly();