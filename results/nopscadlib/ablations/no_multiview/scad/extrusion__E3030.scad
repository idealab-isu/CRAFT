// Parameters
profile_width = 30; //[15:60:1]
profile_height = 30; //[15:60:1]
length = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 2.2; //[1.1:4.4:0.1]
slot_opening = 6.2; //[3.1:12.4:0.1]
slot_cavity_width = 11.0; //[5.5:22.0:0.1]
slot_depth = 8.0; //[4.0:16.0:0.1]
center_bore_diameter = 8.2; //[4.1:16.4:0.1]
web_thickness = 2.0; //[1.0:4.0:0.1]
corner_hole_diameter = 4.2; //[2.1:8.4:0.1]
corner_hole_inset = 7.5; //[3.75:15.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      translate([0, 0, center*(0) + (1-center)*(length/2)])
        cube([profile_width, profile_height, length], center=true);
      
      // T-slot channels
      union() {
        translate([profile_width/2 - (slot_depth + overlap)/2, 0, center*(0) + (1-center)*(length/2)])
          cube([slot_depth + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([-profile_width/2 + (slot_depth + overlap)/2, 0, center*(0) + (1-center)*(length/2)])
          cube([slot_depth + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([0, profile_height/2 - (slot_depth + overlap)/2, center*(0) + (1-center)*(length/2)])
          cube([slot_cavity_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, -profile_height/2 + (slot_depth + overlap)/2, center*(0) + (1-center)*(length/2)])
          cube([slot_cavity_width, slot_depth + overlap, length + 2*overlap], center=true);
      }
      
      // T-slot mouths
      union() {
        translate([profile_width/2 - (slot_depth + overlap)/2, 0, center*(0) + (1-center)*(length/2)])
          cube([slot_depth + overlap, slot_opening, length + 2*overlap], center=true);
        translate([-profile_width/2 + (slot_depth + overlap)/2, 0, center*(0) + (1-center)*(length/2)])
          cube([slot_depth + overlap, slot_opening, length + 2*overlap], center=true);
        translate([0, profile_height/2 - (slot_depth + overlap)/2, center*(0) + (1-center)*(length/2)])
          cube([slot_opening, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, -profile_height/2 + (slot_depth + overlap)/2, center*(0) + (1-center)*(length/2)])
          cube([slot_opening, slot_depth + overlap, length + 2*overlap], center=true);
      }
      
      // Center bore
      translate([0, 0, center*(0) + (1-center)*(length/2)])
        cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([profile_width/2 - corner_hole_inset, profile_height/2 - corner_hole_inset, center*(0) + (1-center)*(length/2)])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([profile_width/2 - corner_hole_inset, -profile_height/2 + corner_hole_inset, center*(0) + (1-center)*(length/2)])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-profile_width/2 + corner_hole_inset, profile_height/2 - corner_hole_inset, center*(0) + (1-center)*(length/2)])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-profile_width/2 + corner_hole_inset, -profile_height/2 + corner_hole_inset, center*(0) + (1-center)*(length/2)])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete detailed geometry
module extrusion_cross_section() {
  color("DimGray") {
    union() {
      // Internal webs
      translate([0, 0, center*(0) + (1-center)*(length/2)]) {
        cube([profile_width - 2*wall_thickness, web_thickness, length], center=true);
        cube([web_thickness, profile_height - 2*wall_thickness, length], center=true);
      }
    }
  }
}

// Box Corner Profile Section - complete detailed geometry
module box_corner_profile_section() {
  color("Black") {
    translate([profile_width/2 - wall_thickness/2, profile_height/2 - wall_thickness/2, center*(0) + (1-center)*(length/2)])
      cube([wall_thickness, wall_thickness, length], center=true);
  }
}

// Box Corner Profile Sections - complete detailed geometry
module box_corner_profile_sections() {
  color("Black") {
    union() {
      box_corner_profile_section();
      translate([-profile_width + wall_thickness, 0, 0]) box_corner_profile_section();
      translate([0, -profile_height + wall_thickness, 0]) box_corner_profile_section();
      translate([-profile_width + wall_thickness, -profile_height + wall_thickness, 0]) box_corner_profile_section();
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