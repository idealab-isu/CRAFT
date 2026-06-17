// Parameters
cross_section_width_mm = 20; //[10:40:1]
cross_section_height_mm = 60; //[30:120:1]
length_mm = 100; //[50:200:1]
center_length = 1; //[0:1:1]
include_corner_holes = 1; //[0:1:1]
eps_mm = 0.8; //[0.2:2:0.1]
wall_thickness_mm = 2.2; //[1.2:4.4:0.1]
t_slot_opening_mm = 6.2; //[4:10:0.1]
t_slot_neck_depth_mm = 3.2; //[2:6:0.1]
t_slot_cavity_width_mm = 11; //[8:16:0.1]
t_slot_cavity_depth_mm = 8; //[5:14:0.1]
center_bore_diameter_mm = 5.2; //[3:10:0.1]
web_thickness_mm = 2.0; //[1.0:4.0:0.1]
corner_hole_diameter_mm = 4.2; //[2.5:8:0.1]
corner_hole_inset_mm = 5.5; //[3:12:0.1]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      translate([0, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
        cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width_mm/2 - (t_slot_neck_depth_mm + eps_mm)/2 + eps_mm/2, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_neck_depth_mm + eps_mm, t_slot_opening_mm, length_mm + 2*eps_mm], center=true);
        translate([cross_section_width_mm/2 - t_slot_neck_depth_mm - (t_slot_cavity_depth_mm + eps_mm)/2 + eps_mm/2, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_cavity_depth_mm + eps_mm, t_slot_cavity_width_mm, length_mm + 2*eps_mm], center=true);
        translate([-cross_section_width_mm/2 + (t_slot_neck_depth_mm + eps_mm)/2 - eps_mm/2, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_neck_depth_mm + eps_mm, t_slot_opening_mm, length_mm + 2*eps_mm], center=true);
        translate([-cross_section_width_mm/2 + t_slot_neck_depth_mm + (t_slot_cavity_depth_mm + eps_mm)/2 - eps_mm/2, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_cavity_depth_mm + eps_mm, t_slot_cavity_width_mm, length_mm + 2*eps_mm], center=true);
        translate([0, cross_section_height_mm/2 - (t_slot_neck_depth_mm + eps_mm)/2 + eps_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_opening_mm, t_slot_neck_depth_mm + eps_mm, length_mm + 2*eps_mm], center=true);
        translate([0, cross_section_height_mm/2 - t_slot_neck_depth_mm - (t_slot_cavity_depth_mm + eps_mm)/2 + eps_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_cavity_width_mm, t_slot_cavity_depth_mm + eps_mm, length_mm + 2*eps_mm], center=true);
        translate([0, -cross_section_height_mm/2 + (t_slot_neck_depth_mm + eps_mm)/2 - eps_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_opening_mm, t_slot_neck_depth_mm + eps_mm, length_mm + 2*eps_mm], center=true);
        translate([0, -cross_section_height_mm/2 + t_slot_neck_depth_mm + (t_slot_cavity_depth_mm + eps_mm)/2 - eps_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_cavity_width_mm, t_slot_cavity_depth_mm + eps_mm, length_mm + 2*eps_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
      
      // Corner holes
      if (include_corner_holes) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, center_length*(0) + (1-center_length)*(length_mm/2)])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, center_length*(0) + (1-center_length)*(length_mm/2)])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, center_length*(0) + (1-center_length)*(length_mm/2)])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, center_length*(0) + (1-center_length)*(length_mm/2)])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
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
      translate([0, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
        cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width_mm/2 - (t_slot_neck_depth_mm + eps_mm)/2 + eps_mm/2, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_neck_depth_mm + eps_mm, t_slot_opening_mm, length_mm + 2*eps_mm], center=true);
        translate([cross_section_width_mm/2 - t_slot_neck_depth_mm - (t_slot_cavity_depth_mm + eps_mm)/2 + eps_mm/2, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_cavity_depth_mm + eps_mm, t_slot_cavity_width_mm, length_mm + 2*eps_mm], center=true);
        translate([-cross_section_width_mm/2 + (t_slot_neck_depth_mm + eps_mm)/2 - eps_mm/2, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_neck_depth_mm + eps_mm, t_slot_opening_mm, length_mm + 2*eps_mm], center=true);
        translate([-cross_section_width_mm/2 + t_slot_neck_depth_mm + (t_slot_cavity_depth_mm + eps_mm)/2 - eps_mm/2, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_cavity_depth_mm + eps_mm, t_slot_cavity_width_mm, length_mm + 2*eps_mm], center=true);
        translate([0, cross_section_height_mm/2 - (t_slot_neck_depth_mm + eps_mm)/2 + eps_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_opening_mm, t_slot_neck_depth_mm + eps_mm, length_mm + 2*eps_mm], center=true);
        translate([0, cross_section_height_mm/2 - t_slot_neck_depth_mm - (t_slot_cavity_depth_mm + eps_mm)/2 + eps_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_cavity_width_mm, t_slot_cavity_depth_mm + eps_mm, length_mm + 2*eps_mm], center=true);
        translate([0, -cross_section_height_mm/2 + (t_slot_neck_depth_mm + eps_mm)/2 - eps_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_opening_mm, t_slot_neck_depth_mm + eps_mm, length_mm + 2*eps_mm], center=true);
        translate([0, -cross_section_height_mm/2 + t_slot_neck_depth_mm + (t_slot_cavity_depth_mm + eps_mm)/2 - eps_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
          cube([t_slot_cavity_width_mm, t_slot_cavity_depth_mm + eps_mm, length_mm + 2*eps_mm], center=true);
      }
      
      // Center bore
      translate([0, 0, center_length*(0) + (1-center_length)*(length_mm/2)])
        cylinder(r=center_bore_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
      
      // Corner holes
      if (include_corner_holes) {
        union() {
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, center_length*(0) + (1-center_length)*(length_mm/2)])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
          translate([cross_section_width_mm/2 - corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, center_length*(0) + (1-center_length)*(length_mm/2)])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, cross_section_height_mm/2 - corner_hole_inset_mm, center_length*(0) + (1-center_length)*(length_mm/2)])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
          translate([-cross_section_width_mm/2 + corner_hole_inset_mm, -cross_section_height_mm/2 + corner_hole_inset_mm, center_length*(0) + (1-center_length)*(length_mm/2)])
            cylinder(r=corner_hole_diameter_mm/2, h=length_mm + 2*eps_mm, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - detailed geometry
module box_corner_profile_section() {
  color("Black") {
    translate([cross_section_width_mm/2 - wall_thickness_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
      cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
  }
}

// Box Corner Profile Sections - detailed geometry
module box_corner_profile_sections() {
  color("Black") {
    union() {
      translate([cross_section_width_mm/2 - wall_thickness_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
      translate([cross_section_width_mm/2 - wall_thickness_mm/2, -cross_section_height_mm/2 + wall_thickness_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
      translate([-cross_section_width_mm/2 + wall_thickness_mm/2, cross_section_height_mm/2 - wall_thickness_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
      translate([-cross_section_width_mm/2 + wall_thickness_mm/2, -cross_section_height_mm/2 + wall_thickness_mm/2, center_length*(0) + (1-center_length)*(length_mm/2)])
        cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  extrusion_cross_section();
  box_corner_profile_section();
  box_corner_profile_sections();
}

assembly();