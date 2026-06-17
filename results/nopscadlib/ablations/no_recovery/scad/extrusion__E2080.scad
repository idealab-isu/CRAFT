// Parameters
cross_section_width_mm = 20; //[10:40:1]
cross_section_height_mm = 80; //[40:160:1]
length_mm = 100; //[50:200:1]
centered_length = 1; //[0:1:1]
corner_hole_enabled = 1; //[0:1:1]
wall_thickness_mm = 2.2; //[1.2:4.4:0.1]
slot_opening_mm = 6.2; //[4:10:0.1]
slot_depth_mm = 6.5; //[3:12:0.1]
center_bore_diameter_mm = 6.8; //[3:14:0.1]
web_thickness_mm = 2.0; //[1.0:4.0:0.1]
corner_hole_diameter_mm = 4.2; //[2:8:0.1]
corner_hole_inset_mm = 5.0; //[3:10:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Extrusion - complete detailed geometry
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
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=32);
      
      // Corner holes
      if (corner_hole_enabled) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
        }
      }
    }
  }
}

// Extrusion Cross Section - detailed geometry
module extrusion_cross_section() {
  color("DimGray") {
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
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=32);
      
      // Corner holes
      if (corner_hole_enabled) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true, $fn=16);
        }
      }
    }
  }
}

// Box Corner Profile Section - detailed geometry
module box_corner_profile_section() {
  color("Black") {
    cube([(cross_section_width_mm - slot_opening_mm)/2, (cross_section_width_mm - slot_opening_mm)/2, length_mm], center=true);
  }
}

// Box Corner Profile Sections - detailed geometry
module box_corner_profile_sections() {
  color("Black") {
    union() {
      translate([cross_section_width_mm/2 - ((cross_section_width_mm - slot_opening_mm)/2)/2, cross_section_height_mm/2 - ((cross_section_width_mm - slot_opening_mm)/2)/2, 0])
        box_corner_profile_section();
      translate([-cross_section_width_mm/2 + ((cross_section_width_mm - slot_opening_mm)/2)/2, cross_section_height_mm/2 - ((cross_section_width_mm - slot_opening_mm)/2)/2, 0])
        box_corner_profile_section();
      translate([cross_section_width_mm/2 - ((cross_section_width_mm - slot_opening_mm)/2)/2, -cross_section_height_mm/2 + ((cross_section_width_mm - slot_opening_mm)/2)/2, 0])
        box_corner_profile_section();
      translate([-cross_section_width_mm/2 + ((cross_section_width_mm - slot_opening_mm)/2)/2, -cross_section_height_mm/2 + ((cross_section_width_mm - slot_opening_mm)/2)/2, 0])
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