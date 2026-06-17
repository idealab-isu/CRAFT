// Parameters
cross_section_width = 30.0; //[15.0:60.0:0.5]
cross_section_height = 60.0; //[30.0:120.0:0.5]
length = 100.0; //[50.0:200.0:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 2.5; //[1.2:5.0:0.1]
slot_opening_width = 6.2; //[4.0:10.0:0.1]
slot_cavity_width = 12.0; //[8.0:18.0:0.1]
slot_depth = 8.0; //[4.0:14.0:0.1]
slot_neck_depth = 2.5; //[1.0:5.0:0.1]
center_bore_diameter = 8.0; //[4.0:16.0:0.1]
internal_void_width = 12.0; //[6.0:22.0:0.1]
internal_void_height = 18.0; //[8.0:30.0:0.1]
web_thickness = 2.5; //[1.2:5.0:0.1]
corner_hole_diameter = 4.2; //[0.0:8.0:0.1]
corner_hole_offset = 7.5; //[4.0:15.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Extrusion Cross Section
module extrusion_cross_section() {
  difference() {
    color("Silver") cube([cross_section_width, cross_section_height, length], center=true);
    union() {
      // T-slot channels
      translate([cross_section_width/2 - (slot_depth + overlap)/2, 0, 0])
        cube([slot_depth + overlap, slot_opening_width, length + 2*overlap], center=true);
      translate([cross_section_width/2 - slot_neck_depth - (slot_depth - slot_neck_depth + overlap)/2, 0, 0])
        cube([slot_depth - slot_neck_depth + overlap, slot_cavity_width, length + 2*overlap], center=true);
      translate([-cross_section_width/2 + (slot_depth + overlap)/2, 0, 0])
        cube([slot_depth + overlap, slot_opening_width, length + 2*overlap], center=true);
      translate([-cross_section_width/2 + slot_neck_depth + (slot_depth - slot_neck_depth + overlap)/2, 0, 0])
        cube([slot_depth - slot_neck_depth + overlap, slot_cavity_width, length + 2*overlap], center=true);
      translate([0, cross_section_height/2 - (slot_depth + overlap)/2, 0])
        cube([slot_opening_width, slot_depth + overlap, length + 2*overlap], center=true);
      translate([0, cross_section_height/2 - slot_neck_depth - (slot_depth - slot_neck_depth + overlap)/2, 0])
        cube([slot_cavity_width, slot_depth - slot_neck_depth + overlap, length + 2*overlap], center=true);
      translate([0, -cross_section_height/2 + (slot_depth + overlap)/2, 0])
        cube([slot_opening_width, slot_depth + overlap, length + 2*overlap], center=true);
      translate([0, -cross_section_height/2 + slot_neck_depth + (slot_depth - slot_neck_depth + overlap)/2, 0])
        cube([slot_cavity_width, slot_depth - slot_neck_depth + overlap, length + 2*overlap], center=true);
    }
    // Center bore and internal voids
    union() {
      cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
      translate([-(internal_void_width/2 + web_thickness/2), 0, 0])
        cube([internal_void_width, internal_void_height, length + 2*overlap], center=true);
      translate([(internal_void_width/2 + web_thickness/2), 0, 0])
        cube([internal_void_width, internal_void_height, length + 2*overlap], center=true);
    }
    // Corner holes
    if (cornerHole) {
      union() {
        translate([cross_section_width/2 - corner_hole_offset, cross_section_height/2 - corner_hole_offset, 0])
          cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
        translate([-cross_section_width/2 + corner_hole_offset, cross_section_height/2 - corner_hole_offset, 0])
          cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
        translate([cross_section_width/2 - corner_hole_offset, -cross_section_height/2 + corner_hole_offset, 0])
          cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
        translate([-cross_section_width/2 + corner_hole_offset, -cross_section_height/2 + corner_hole_offset, 0])
          cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
      }
    }
  }
}

// Box Corner Profile Section
module box_corner_profile_section() {
  color("DimGray") cube([wall_thickness, wall_thickness, length], center=true);
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  union() {
    box_corner_profile_section();
    rotate([0, 0, 90]) box_corner_profile_section();
    rotate([0, 0, 180]) box_corner_profile_section();
    rotate([0, 0, 270]) box_corner_profile_section();
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