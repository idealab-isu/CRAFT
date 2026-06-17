// Parameters
profile_width_mm = 20.0; //[10.0:40.0:0.5]
profile_height_mm = 40.0; //[20.0:80.0:0.5]
length_mm = 100.0; //[50.0:200.0:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness_mm = 2.0; //[1.0:4.0:0.25]
slot_opening_mm = 6.0; //[4.0:10.0:0.25]
slot_depth_mm = 6.0; //[3.0:10.0:0.25]
slot_cavity_width_mm = 10.0; //[6.0:16.0:0.25]
slot_cavity_height_mm = 8.0; //[5.0:14.0:0.25]
web_thickness_mm = 2.0; //[1.0:4.0:0.25]
center_bore_d_mm = 6.8; //[4.0:12.0:0.1]
corner_hole_d_mm = 4.2; //[2.5:8.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main profile body
      cube([profile_width_mm, profile_height_mm, length_mm], center=true);
      
      // T-slot channels and cavities
      union() {
        translate([profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([-profile_width_mm/2 + (slot_depth_mm + overlap_mm)/2, 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_opening_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -profile_height_mm/2 + (slot_depth_mm + overlap_mm)/2, 0])
          cube([slot_opening_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([profile_width_mm/2 - (slot_depth_mm + overlap_mm)/2 - (slot_depth_mm*0.15), 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_height_mm, length_mm + 2*overlap_mm], center=true);
        translate([-profile_width_mm/2 + (slot_depth_mm + overlap_mm)/2 + (slot_depth_mm*0.15), 0, 0])
          cube([slot_depth_mm + overlap_mm, slot_cavity_height_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, profile_height_mm/2 - (slot_depth_mm + overlap_mm)/2 - (slot_depth_mm*0.15), 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
        translate([0, -profile_height_mm/2 + (slot_depth_mm + overlap_mm)/2 + (slot_depth_mm*0.15), 0])
          cube([slot_cavity_width_mm, slot_depth_mm + overlap_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Center bore and internal webs
      union() {
        cylinder(r=center_bore_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
        cube([profile_width_mm - 2*wall_thickness_mm, web_thickness_mm, length_mm + 2*overlap_mm], center=true);
        cube([web_thickness_mm, profile_height_mm - 2*wall_thickness_mm, length_mm + 2*overlap_mm], center=true);
      }
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([profile_width_mm/2 - wall_thickness_mm - corner_hole_d_mm/2, profile_height_mm/2 - wall_thickness_mm - corner_hole_d_mm/2, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-profile_width_mm/2 + wall_thickness_mm + corner_hole_d_mm/2, profile_height_mm/2 - wall_thickness_mm - corner_hole_d_mm/2, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([profile_width_mm/2 - wall_thickness_mm - corner_hole_d_mm/2, -profile_height_mm/2 + wall_thickness_mm + corner_hole_d_mm/2, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
          translate([-profile_width_mm/2 + wall_thickness_mm + corner_hole_d_mm/2, -profile_height_mm/2 + wall_thickness_mm + corner_hole_d_mm/2, 0])
            cylinder(r=corner_hole_d_mm/2, h=length_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete detailed geometry
module extrusion_cross_section() {
  color("DimGray") {
    cube([profile_width_mm, profile_height_mm, web_thickness_mm], center=true);
  }
}

// Box Corner Profile Section - complete detailed geometry
module box_corner_profile_section() {
  color("Black") {
    translate([profile_width_mm/2 - wall_thickness_mm/2, profile_height_mm/2 - wall_thickness_mm/2, 0])
      cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
  }
}

// Box Corner Profile Sections - complete detailed geometry
module box_corner_profile_sections() {
  color("Black") {
    translate([-profile_width_mm/2 + wall_thickness_mm/2, -profile_height_mm/2 + wall_thickness_mm/2, 0])
      cube([wall_thickness_mm, wall_thickness_mm, length_mm], center=true);
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