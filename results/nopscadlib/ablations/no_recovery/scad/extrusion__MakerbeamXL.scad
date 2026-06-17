// Parameters
cross_section_width_mm = 15.0; //[7.5:30.0:0.5]
cross_section_height_mm = 15.0; //[7.5:30.0:0.5]
length_mm = 100.0; //[50.0:200.0:1]
center_model = 1; //[0:1:1]
include_corner_holes = 1; //[0:1:1]
wall_thickness_mm = 1.6; //[0.8:3.2:0.1]
slot_opening_mm = 3.2; //[1.6:6.4:0.1]
slot_depth_mm = 3.0; //[1.5:6.0:0.1]
slot_inner_width_mm = 6.0; //[3.0:10.0:0.1]
slot_inner_depth_mm = 2.5; //[1.0:5.0:0.1]
center_bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
corner_hole_diameter_mm = 3.0; //[1.5:6.0:0.1]
corner_hole_inset_mm = 3.0; //[1.5:6.0:0.1]
cut_clearance_mm = 0.5; //[0.2:1.5:0.1]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // Inner void
      translate([0, 0, 0])
        cube([cross_section_width_mm - 2*wall_thickness_mm, cross_section_height_mm - 2*wall_thickness_mm, length_mm + 2*cut_clearance_mm], center=true);
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*cut_clearance_mm, center=true, $fn=32);
      
      // T-slot channels
      union() {
        translate([cross_section_width_mm/2 - (slot_depth_mm + slot_inner_depth_mm)/2, 0, 0])
          cube([slot_depth_mm + slot_inner_depth_mm, slot_inner_width_mm, length_mm + 2*cut_clearance_mm], center=true);
        translate([cross_section_width_mm/2 - slot_depth_mm/2, 0, 0])
          cube([slot_depth_mm, slot_opening_mm, length_mm + 2*cut_clearance_mm], center=true);
        translate([0, cross_section_height_mm/2 - (slot_depth_mm + slot_inner_depth_mm)/2, 0])
          cube([slot_inner_width_mm, slot_depth_mm + slot_inner_depth_mm, length_mm + 2*cut_clearance_mm], center=true);
        translate([0, cross_section_height_mm/2 - slot_depth_mm/2, 0])
          cube([slot_opening_mm, slot_depth_mm, length_mm + 2*cut_clearance_mm], center=true);
        translate([-cross_section_width_mm/2 + (slot_depth_mm + slot_inner_depth_mm)/2, 0, 0])
          cube([slot_depth_mm + slot_inner_depth_mm, slot_inner_width_mm, length_mm + 2*cut_clearance_mm], center=true);
        translate([-cross_section_width_mm/2 + slot_depth_mm/2, 0, 0])
          cube([slot_depth_mm, slot_opening_mm, length_mm + 2*cut_clearance_mm], center=true);
        translate([0, -cross_section_height_mm/2 + (slot_depth_mm + slot_inner_depth_mm)/2, 0])
          cube([slot_inner_width_mm, slot_depth_mm + slot_inner_depth_mm, length_mm + 2*cut_clearance_mm], center=true);
        translate([0, -cross_section_height_mm/2 + slot_depth_mm/2, 0])
          cube([slot_opening_mm, slot_depth_mm, length_mm + 2*cut_clearance_mm], center=true);
      }
      
      // Corner holes
      if (include_corner_holes) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_clearance_mm, center=true, $fn=16);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_clearance_mm, center=true, $fn=16);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_clearance_mm, center=true, $fn=16);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_clearance_mm, center=true, $fn=16);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete detailed geometry
module extrusion_cross_section() {
  color("Silver") {
    cube([cross_section_width_mm, cross_section_height_mm, wall_thickness_mm], center=true);
  }
}

// Box Corner Profile Section - complete detailed geometry
module box_corner_profile_section() {
  color("Silver") {
    cube([cross_section_width_mm/2, cross_section_height_mm/2, wall_thickness_mm], center=true);
  }
}

// Box Corner Profile Sections - complete detailed geometry
module box_corner_profile_sections() {
  color("Silver") {
    union() {
      translate([cross_section_width_mm/4, cross_section_height_mm/4, 0])
        box_corner_profile_section();
      translate([-cross_section_width_mm/4, cross_section_height_mm/4, 0])
        box_corner_profile_section();
      translate([cross_section_width_mm/4, -cross_section_height_mm/4, 0])
        box_corner_profile_section();
      translate([-cross_section_width_mm/4, -cross_section_height_mm/4, 0])
        box_corner_profile_section();
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, length_mm/2 + wall_thickness_mm/2])
    extrusion_cross_section();
  translate([0, 0, length_mm/2 + wall_thickness_mm])
    box_corner_profile_sections();
}

assembly();