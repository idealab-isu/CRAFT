// Parameters
cross_section_width_mm = 15; //[7.5:30:0.5]
cross_section_height_mm = 15; //[7.5:30:0.5]
length_mm = 100; //[50:200:1]
centered = 1; //[0:1:1]
corner_hole = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
wall_thickness_mm = 2; //[1:4:0.25]
slot_opening_mm = 3; //[2:6:0.25]
slot_cavity_width_mm = 6; //[4:10:0.25]
slot_depth_mm = 4.5; //[2.5:7.5:0.25]
center_bore_diameter_mm = 5; //[3:10:0.25]
corner_hole_diameter_mm = 3; //[0:6:0.25]
corner_hole_inset_mm = 3.5; //[2:6:0.25]

// Extrusion Profile Body
module extrusion_profile_body() {
  color("Silver") {
    cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
  }
}

// T-Slot Channels
module t_slot_channels() {
  color("DimGray") {
    union() {
      translate([cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
        cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
      translate([cross_section_width_mm/2 - (slot_depth_mm + overlap_mm)/2 - (slot_opening_mm/2), 0, 0])
        cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
      translate([-cross_section_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
        cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
      translate([-cross_section_width_mm/2 + (slot_depth_mm + overlap_mm)/2 + (slot_opening_mm/2), 0, 0])
        cube([slot_depth_mm + overlap_mm, slot_cavity_width_mm, length_mm + 2*overlap_mm], center=true);
      translate([0, cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
        cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      translate([0, cross_section_height_mm/2 - (slot_depth_mm + overlap_mm)/2 - (slot_opening_mm/2), 0])
        cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      translate([0, -cross_section_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
        cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      translate([0, -cross_section_height_mm/2 + (slot_depth_mm + overlap_mm)/2 + (slot_opening_mm/2), 0])
        cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
    }
  }
}

// Center Bore or Void
module center_bore_or_void() {
  color("Black") {
    cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);
  }
}

// Corner Holes Optional
module corner_holes_optional() {
  color("Black") {
    if (corner_hole) {
      union() {
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=(corner_hole_diameter_mm*corner_hole)/2, h=length_mm + 2*overlap_mm, center=true);
        translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=(corner_hole_diameter_mm*corner_hole)/2, h=length_mm + 2*overlap_mm, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
          cylinder(r=(corner_hole_diameter_mm*corner_hole)/2, h=length_mm + 2*overlap_mm, center=true);
        translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
          cylinder(r=(corner_hole_diameter_mm*corner_hole)/2, h=length_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Box Corner Profile Section
module box_corner_profile_section() {
  color("Silver") {
    cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
  }
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  color("Silver") {
    union() {
      box_corner_profile_section();
      translate([cross_section_width_mm/2 - wall_thickness_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2, 0])
        box_corner_profile_section();
    }
  }
}

// Extrusion Cross Section
module extrusion_cross_section() {
  difference() {
    extrusion_profile_body();
    t_slot_channels();
    center_bore_or_void();
    corner_holes_optional();
  }
}

// Extrusion
module extrusion() {
  union() {
    extrusion_cross_section();
    box_corner_profile_sections();
  }
}

// Assembly
module assembly() {
  extrusion();
}

assembly();