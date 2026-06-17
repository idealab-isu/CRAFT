// Parameters
profile_width = 20.0; //[10.0:40.0:0.5]
profile_height = 20.0; //[10.0:40.0:0.5]
length = 100.0; //[50.0:200.0:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 2.0; //[1.0:4.0:0.25]
slot_depth = 6.0; //[3.0:10.0:0.25]
slot_neck_width = 6.2; //[4.0:8.0:0.1]
slot_cavity_width = 10.5; //[7.0:14.0:0.1]
slot_cavity_inset = 2.0; //[1.0:4.0:0.25]
center_bore_diameter = 5.0; //[3.0:8.0:0.1]
web_thickness = 2.0; //[1.0:4.0:0.25]
corner_hole_diameter = 3.2; //[2.0:6.0:0.1]
corner_hole_inset = 5.0; //[3.0:8.0:0.25]
overlap = 1.0; //[0.5:2.0:0.25]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([profile_width, profile_height, length], center=true);
      
      // T-slot channels
      union() {
        translate([profile_width/2 - (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_neck_width, length + 2*overlap], center=true);
        translate([profile_width/2 - slot_cavity_inset - (slot_depth - slot_cavity_inset + overlap)/2, 0, 0])
          cube([slot_depth - slot_cavity_inset + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([-profile_width/2 + (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_neck_width, length + 2*overlap], center=true);
        translate([-profile_width/2 + slot_cavity_inset + (slot_depth - slot_cavity_inset + overlap)/2, 0, 0])
          cube([slot_depth - slot_cavity_inset + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([0, profile_height/2 - (slot_depth + overlap)/2, 0])
          cube([slot_neck_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, profile_height/2 - slot_cavity_inset - (slot_depth - slot_cavity_inset + overlap)/2, 0])
          cube([slot_cavity_width, slot_depth - slot_cavity_inset + overlap, length + 2*overlap], center=true);
        translate([0, -profile_height/2 + (slot_depth + overlap)/2, 0])
          cube([slot_neck_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, -profile_height/2 + slot_cavity_inset + (slot_depth - slot_cavity_inset + overlap)/2, 0])
          cube([slot_cavity_width, slot_depth - slot_cavity_inset + overlap, length + 2*overlap], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
      
      // Internal webs
      union() {
        translate([0, 0, 0])
          cube([profile_width - 2*wall_thickness, web_thickness, length], center=true);
        translate([0, 0, 0])
          cube([web_thickness, profile_height - 2*wall_thickness, length], center=true);
      }
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([profile_width/2 - corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([profile_width/2 - corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-profile_width/2 + corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-profile_width/2 + corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
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
      cube([profile_width, profile_height, length], center=true);
      
      // T-slot channels
      union() {
        translate([profile_width/2 - (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_neck_width, length + 2*overlap], center=true);
        translate([profile_width/2 - slot_cavity_inset - (slot_depth - slot_cavity_inset + overlap)/2, 0, 0])
          cube([slot_depth - slot_cavity_inset + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([-profile_width/2 + (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_neck_width, length + 2*overlap], center=true);
        translate([-profile_width/2 + slot_cavity_inset + (slot_depth - slot_cavity_inset + overlap)/2, 0, 0])
          cube([slot_depth - slot_cavity_inset + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([0, profile_height/2 - (slot_depth + overlap)/2, 0])
          cube([slot_neck_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, profile_height/2 - slot_cavity_inset - (slot_depth - slot_cavity_inset + overlap)/2, 0])
          cube([slot_cavity_width, slot_depth - slot_cavity_inset + overlap, length + 2*overlap], center=true);
        translate([0, -profile_height/2 + (slot_depth + overlap)/2, 0])
          cube([slot_neck_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, -profile_height/2 + slot_cavity_inset + (slot_depth - slot_cavity_inset + overlap)/2, 0])
          cube([slot_cavity_width, slot_depth - slot_cavity_inset + overlap, length + 2*overlap], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
      
      // Internal webs
      union() {
        translate([0, 0, 0])
          cube([profile_width - 2*wall_thickness, web_thickness, length], center=true);
        translate([0, 0, 0])
          cube([web_thickness, profile_height - 2*wall_thickness, length], center=true);
      }
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([profile_width/2 - corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([profile_width/2 - corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-profile_width/2 + corner_hole_inset, profile_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-profile_width/2 + corner_hole_inset, -profile_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - detailed geometry
module box_corner_profile_section() {
  color("Black") {
    cube([profile_width, profile_height, length], center=true);
  }
}

// Box Corner Profile Sections - detailed geometry
module box_corner_profile_sections() {
  color("Gray") {
    union() {
      box_corner_profile_section();
      translate([0, 0, 0])
        box_corner_profile_section();
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, 0])
    extrusion_cross_section();
  translate([0, 0, 0])
    box_corner_profile_section();
  translate([0, 0, 0])
    box_corner_profile_sections();
}

assembly();