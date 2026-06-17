// Parameters
profile_width = 15; //[7.5:30:0.5]
profile_height = 15; //[7.5:30:0.5]
length = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 1.6; //[0.8:3.2:0.1]
slot_opening = 3.2; //[1.6:6.4:0.1]
slot_depth = 3.8; //[2:7.5:0.1]
slot_cavity_width = 6.2; //[3:10:0.1]
slot_cavity_depth = 2.2; //[1:5:0.1]
center_bore_diameter = 5; //[2.5:10:0.1]
corner_hole_diameter = 3; //[1.5:6:0.1]
corner_hole_inset = 3.75; //[2:7:0.05]
overlap = 1; //[0.5:2:0.1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main profile body
      cube([profile_width, profile_height, length], center=true);
      
      // T-slot channels
      union() {
        translate([profile_width/2 - (slot_depth + overlap*2)/2 + overlap, 0, 0])
          cube([slot_depth + overlap*2, slot_opening, length + overlap*2], center=true);
        translate([profile_width/2 - slot_depth - (slot_cavity_depth + overlap*2)/2 + overlap, 0, 0])
          cube([slot_cavity_depth + overlap*2, slot_cavity_width, length + overlap*2], center=true);
        translate([-profile_width/2 + (slot_depth + overlap*2)/2 - overlap, 0, 0])
          cube([slot_depth + overlap*2, slot_opening, length + overlap*2], center=true);
        translate([-profile_width/2 + slot_depth + (slot_cavity_depth + overlap*2)/2 - overlap, 0, 0])
          cube([slot_cavity_depth + overlap*2, slot_cavity_width, length + overlap*2], center=true);
        translate([0, profile_height/2 - (slot_depth + overlap*2)/2 + overlap, 0])
          cube([slot_opening, slot_depth + overlap*2, length + overlap*2], center=true);
        translate([0, profile_height/2 - slot_depth - (slot_cavity_depth + overlap*2)/2 + overlap, 0])
          cube([slot_cavity_width, slot_cavity_depth + overlap*2, length + overlap*2], center=true);
        translate([0, -profile_height/2 + (slot_depth + overlap*2)/2 - overlap, 0])
          cube([slot_opening, slot_depth + overlap*2, length + overlap*2], center=true);
        translate([0, -profile_height/2 + slot_depth + (slot_cavity_depth + overlap*2)/2 - overlap, 0])
          cube([slot_cavity_width, slot_cavity_depth + overlap*2, length + overlap*2], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        rotate([90, 0, 0])
        cylinder(r=center_bore_diameter/2, h=length + overlap*2, center=true);
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([profile_width/2 - corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            rotate([90, 0, 0])
            cylinder(r=corner_hole_diameter/2, h=length + overlap*2, center=true);
          translate([-profile_width/2 + corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            rotate([90, 0, 0])
            cylinder(r=corner_hole_diameter/2, h=length + overlap*2, center=true);
          translate([-profile_width/2 + corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            rotate([90, 0, 0])
            cylinder(r=corner_hole_diameter/2, h=length + overlap*2, center=true);
          translate([profile_width/2 - corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            rotate([90, 0, 0])
            cylinder(r=corner_hole_diameter/2, h=length + overlap*2, center=true);
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
      cube([profile_width, profile_height, wall_thickness], center=true);
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([profile_width/2 - corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            rotate([90, 0, 0])
            cylinder(r=corner_hole_diameter/2, h=wall_thickness + overlap, center=true);
          translate([-profile_width/2 + corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            rotate([90, 0, 0])
            cylinder(r=corner_hole_diameter/2, h=wall_thickness + overlap, center=true);
          translate([-profile_width/2 + corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            rotate([90, 0, 0])
            cylinder(r=corner_hole_diameter/2, h=wall_thickness + overlap, center=true);
          translate([profile_width/2 - corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            rotate([90, 0, 0])
            cylinder(r=corner_hole_diameter/2, h=wall_thickness + overlap, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("Black") {
    cube([wall_thickness, wall_thickness, length], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("Black") {
    union() {
      translate([profile_width/2 - wall_thickness/2, profile_height/2 - wall_thickness/2, 0])
        box_corner_profile_section();
      translate([-profile_width/2 + wall_thickness/2, profile_height/2 - wall_thickness/2, 0])
        box_corner_profile_section();
      translate([profile_width/2 - wall_thickness/2, -profile_height/2 + wall_thickness/2, 0])
        box_corner_profile_section();
      translate([-profile_width/2 + wall_thickness/2, -profile_height/2 + wall_thickness/2, 0])
        box_corner_profile_section();
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, length/2 - wall_thickness/2])
    extrusion_cross_section();
  box_corner_profile_sections();
}

assembly();