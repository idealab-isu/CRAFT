// Parameters
cross_section_width = 40.0; //[20.0:80.0:0.5]
cross_section_height = 40.0; //[20.0:80.0:0.5]
length = 100.0; //[50.0:200.0:1]
outer_corner_radius = 1.5; //[0.5:3.0:0.1]
slot_opening_width = 8.2; //[5.0:12.0:0.1]
slot_opening_depth = 3.2; //[2.0:6.0:0.1]
slot_cavity_width = 13.0; //[9.0:18.0:0.1]
slot_cavity_depth = 8.0; //[5.0:14.0:0.1]
center_bore_diameter = 8.0; //[4.0:16.0:0.1]
web_thickness = 3.0; //[1.5:6.0:0.1]
corner_hole_diameter = 4.2; //[2.0:8.0:0.1]
corner_hole_inset = 10.0; //[6.0:16.0:0.5]
cut_through_height = 120.0; //[60.0:240.0:1]
overlap = 1.0; //[0.5:2.0:0.1]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width, cross_section_height, length], center=true);
      
      // T-slot channels
      union() {
        for (i = [-1, 1]) {
          translate([i * (cross_section_width/2 - (slot_opening_depth + overlap)/2), 0, 0])
            cube([slot_opening_depth + overlap, slot_opening_width, cut_through_height], center=true);
          translate([i * (cross_section_width/2 - slot_opening_depth - (slot_cavity_depth + overlap)/2), 0, 0])
            cube([slot_cavity_depth + overlap, slot_cavity_width, cut_through_height], center=true);
          translate([0, i * (cross_section_height/2 - (slot_opening_depth + overlap)/2), 0])
            cube([slot_opening_width, slot_opening_depth + overlap, cut_through_height], center=true);
          translate([0, i * (cross_section_height/2 - slot_opening_depth - (slot_cavity_depth + overlap)/2), 0])
            cube([slot_cavity_width, slot_cavity_depth + overlap, cut_through_height], center=true);
        }
      }
      
      // Center bore
      cylinder(r=center_bore_diameter/2, h=cut_through_height, center=true);
      
      // Corner holes
      if (cornerHole) {
        for (i = [-1, 1], j = [-1, 1]) {
          translate([i * (cross_section_width/2 - corner_hole_inset), j * (cross_section_height/2 - corner_hole_inset), 0])
            cylinder(r=corner_hole_diameter/2, h=cut_through_height, center=true);
        }
      }
      
      // Outer corner cuts
      for (i = [-1, 1], j = [-1, 1]) {
        translate([i * (cross_section_width/2 - outer_corner_radius), j * (cross_section_height/2 - outer_corner_radius), 0])
          cylinder(r=outer_corner_radius, h=cut_through_height, center=true);
      }
    }
    
    // Internal webbing
    union() {
      cube([cross_section_width - 2*(slot_opening_depth + slot_cavity_depth + overlap), web_thickness, length], center=true);
      cube([web_thickness, cross_section_height - 2*(slot_opening_depth + slot_cavity_depth + overlap), length], center=true);
    }
  }
}

// Extrusion Cross Section - detailed geometry
module extrusion_cross_section() {
  color("DimGray") {
    difference() {
      // Main body
      cube([cross_section_width, cross_section_height, length], center=true);
      
      // T-slot channels
      union() {
        for (i = [-1, 1]) {
          translate([i * (cross_section_width/2 - (slot_opening_depth + overlap)/2), 0, 0])
            cube([slot_opening_depth + overlap, slot_opening_width, cut_through_height], center=true);
          translate([i * (cross_section_width/2 - slot_opening_depth - (slot_cavity_depth + overlap)/2), 0, 0])
            cube([slot_cavity_depth + overlap, slot_cavity_width, cut_through_height], center=true);
          translate([0, i * (cross_section_height/2 - (slot_opening_depth + overlap)/2), 0])
            cube([slot_opening_width, slot_opening_depth + overlap, cut_through_height], center=true);
          translate([0, i * (cross_section_height/2 - slot_opening_depth - (slot_cavity_depth + overlap)/2), 0])
            cube([slot_cavity_width, slot_cavity_depth + overlap, cut_through_height], center=true);
        }
      }
      
      // Center bore
      cylinder(r=center_bore_diameter/2, h=cut_through_height, center=true);
      
      // Corner holes
      if (cornerHole) {
        for (i = [-1, 1], j = [-1, 1]) {
          translate([i * (cross_section_width/2 - corner_hole_inset), j * (cross_section_height/2 - corner_hole_inset), 0])
            cylinder(r=corner_hole_diameter/2, h=cut_through_height, center=true);
        }
      }
      
      // Outer corner cuts
      for (i = [-1, 1], j = [-1, 1]) {
        translate([i * (cross_section_width/2 - outer_corner_radius), j * (cross_section_height/2 - outer_corner_radius), 0])
          cylinder(r=outer_corner_radius, h=cut_through_height, center=true);
      }
    }
  }
}

// Box Corner Profile Section - detailed geometry
module box_corner_profile_section() {
  color("Black") {
    for (i = [-1, 1], j = [-1, 1]) {
      translate([i * (cross_section_width/2 - outer_corner_radius), j * (cross_section_height/2 - outer_corner_radius), 0])
        cylinder(r=outer_corner_radius, h=cut_through_height, center=true);
    }
  }
}

// Box Corner Profile Sections - detailed geometry
module box_corner_profile_sections() {
  color("Gray") {
    for (i = [-1, 1], j = [-1, 1]) {
      translate([i * (cross_section_width/2 - outer_corner_radius), j * (cross_section_height/2 - outer_corner_radius), 0])
        cylinder(r=outer_corner_radius, h=cut_through_height, center=true);
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, length/2 + 5]) extrusion_cross_section();
  translate([0, 0, length + 10]) box_corner_profile_section();
  translate([0, 0, length + 15]) box_corner_profile_sections();
}

assembly();