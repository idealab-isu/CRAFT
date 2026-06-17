// Parameters
profile_width_mm = 20.0; //[10.0:40.0:0.5]
profile_height_mm = 40.0; //[20.0:80.0:0.5]
length_mm = 100.0; //[50.0:200.0:1]
center_model = 1; //[0:1:1]
include_corner_holes = 1; //[0:1:1]
wall_thickness_mm = 2.0; //[1.0:4.0:0.25]
slot_opening_mm = 6.0; //[4.0:8.0:0.25]
slot_cavity_mm = 10.0; //[7.0:14.0:0.5]
slot_depth_mm = 6.0; //[4.0:10.0:0.25]
center_bore_diameter_mm = 5.2; //[3.0:10.0:0.1]
corner_hole_diameter_mm = 4.2; //[2.0:8.0:0.1]
corner_hole_inset_mm = 6.0; //[4.0:10.0:0.25]
cut_extra_mm = 0.5; //[0.2:2.0:0.1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main extrusion body
      cube([profile_width_mm, profile_height_mm, length_mm], center=true);
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*cut_extra_mm, center=true, $fn=32);
      
      // T-slot channels
      union() {
        // X positive
        translate([profile_width_mm/2 - (slot_depth_mm + cut_extra_mm)/2, 0, 0])
          cube([slot_depth_mm + cut_extra_mm, slot_cavity_mm, length_mm + 2*cut_extra_mm], center=true);
        translate([profile_width_mm/2 - (slot_depth_mm + cut_extra_mm)/2, 0, 0])
          cube([slot_depth_mm + cut_extra_mm, slot_opening_mm, length_mm + 2*cut_extra_mm], center=true);
        
        // X negative
        translate([-profile_width_mm/2 + (slot_depth_mm + cut_extra_mm)/2, 0, 0])
          cube([slot_depth_mm + cut_extra_mm, slot_cavity_mm, length_mm + 2*cut_extra_mm], center=true);
        translate([-profile_width_mm/2 + (slot_depth_mm + cut_extra_mm)/2, 0, 0])
          cube([slot_depth_mm + cut_extra_mm, slot_opening_mm, length_mm + 2*cut_extra_mm], center=true);
        
        // Y positive
        translate([0, profile_height_mm/2 - (slot_depth_mm + cut_extra_mm)/2, 0])
          cube([slot_cavity_mm, slot_depth_mm + cut_extra_mm, length_mm + 2*cut_extra_mm], center=true);
        translate([0, profile_height_mm/2 - (slot_depth_mm + cut_extra_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + cut_extra_mm, length_mm + 2*cut_extra_mm], center=true);
        
        // Y negative
        translate([0, -profile_height_mm/2 + (slot_depth_mm + cut_extra_mm)/2, 0])
          cube([slot_cavity_mm, slot_depth_mm + cut_extra_mm, length_mm + 2*cut_extra_mm], center=true);
        translate([0, -profile_height_mm/2 + (slot_depth_mm + cut_extra_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + cut_extra_mm, length_mm + 2*cut_extra_mm], center=true);
      }
      
      // Corner holes
      if (include_corner_holes) {
        union() {
          translate([profile_width_mm/2 - corner_hole_inset_mm, profile_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_extra_mm, center=true, $fn=32);
          translate([-profile_width_mm/2 + corner_hole_inset_mm, profile_height_mm/2 - corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_extra_mm, center=true, $fn=32);
          translate([-profile_width_mm/2 + corner_hole_inset_mm, -profile_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_extra_mm, center=true, $fn=32);
          translate([profile_width_mm/2 - corner_hole_inset_mm, -profile_height_mm/2 + corner_hole_inset_mm, 0])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*cut_extra_mm, center=true, $fn=32);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  color("DimGray") {
    difference() {
      // Cross section body
      cube([profile_width_mm, profile_height_mm, wall_thickness_mm], center=true);
      
      // Corner profiles
      union() {
        translate([profile_width_mm/2 - corner_hole_inset_mm/2, profile_height_mm/2 - corner_hole_inset_mm/2, 0])
          cube([corner_hole_inset_mm, corner_hole_inset_mm, wall_thickness_mm], center=true);
        translate([-profile_width_mm/2 + corner_hole_inset_mm/2, profile_height_mm/2 - corner_hole_inset_mm/2, 0])
          cube([corner_hole_inset_mm, corner_hole_inset_mm, wall_thickness_mm], center=true);
        translate([profile_width_mm/2 - corner_hole_inset_mm/2, -profile_height_mm/2 + corner_hole_inset_mm/2, 0])
          cube([corner_hole_inset_mm, corner_hole_inset_mm, wall_thickness_mm], center=true);
        translate([-profile_width_mm/2 + corner_hole_inset_mm/2, -profile_height_mm/2 + corner_hole_inset_mm/2, 0])
          cube([corner_hole_inset_mm, corner_hole_inset_mm, wall_thickness_mm], center=true);
      }
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("Black") {
    cube([corner_hole_inset_mm, corner_hole_inset_mm, wall_thickness_mm], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("Black") {
    union() {
      translate([profile_width_mm/2 - corner_hole_inset_mm/2, profile_height_mm/2 - corner_hole_inset_mm/2, 0])
        box_corner_profile_section();
      translate([-profile_width_mm/2 + corner_hole_inset_mm/2, profile_height_mm/2 - corner_hole_inset_mm/2, 0])
        box_corner_profile_section();
      translate([profile_width_mm/2 - corner_hole_inset_mm/2, -profile_height_mm/2 + corner_hole_inset_mm/2, 0])
        box_corner_profile_section();
      translate([-profile_width_mm/2 + corner_hole_inset_mm/2, -profile_height_mm/2 + corner_hole_inset_mm/2, 0])
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