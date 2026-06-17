// Parameters
cross_section_width = 15; //[7.5:30:0.5]
cross_section_height = 15; //[7.5:30:0.5]
length = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 1.6; //[0.8:3.2:0.1]
slot_opening_width = 6.0; //[3.0:10.0:0.1]
slot_inner_width = 8.0; //[4.0:12.0:0.1]
slot_depth = 4.2; //[2.0:7.0:0.1]
slot_neck_depth = 2.0; //[1.0:4.0:0.1]
center_bore_diameter = 5.0; //[2.0:8.0:0.1]
corner_hole_diameter = 3.0; //[1.5:6.0:0.1]
corner_hole_inset = 3.5; //[2.0:6.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width, cross_section_height, length], center=true);
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
      
      // T-slot channels
      union() {
        // X-axis slots
        translate([cross_section_width/2 - (slot_neck_depth + 2*overlap)/2 + overlap, 0, 0])
          cube([slot_neck_depth + 2*overlap, slot_opening_width, length + 2*overlap], center=true);
        translate([cross_section_width/2 - slot_neck_depth - (slot_depth - slot_neck_depth + 2*overlap)/2 + overlap, 0, 0])
          cube([slot_depth - slot_neck_depth + 2*overlap, slot_inner_width, length + 2*overlap], center=true);
        translate([-cross_section_width/2 + (slot_neck_depth + 2*overlap)/2 - overlap, 0, 0])
          cube([slot_neck_depth + 2*overlap, slot_opening_width, length + 2*overlap], center=true);
        translate([-cross_section_width/2 + slot_neck_depth + (slot_depth - slot_neck_depth + 2*overlap)/2 - overlap, 0, 0])
          cube([slot_depth - slot_neck_depth + 2*overlap, slot_inner_width, length + 2*overlap], center=true);
        
        // Y-axis slots
        translate([0, cross_section_height/2 - (slot_neck_depth + 2*overlap)/2 + overlap, 0])
          cube([slot_opening_width, slot_neck_depth + 2*overlap, length + 2*overlap], center=true);
        translate([0, cross_section_height/2 - slot_neck_depth - (slot_depth - slot_neck_depth + 2*overlap)/2 + overlap, 0])
          cube([slot_inner_width, slot_depth - slot_neck_depth + 2*overlap, length + 2*overlap], center=true);
        translate([0, -cross_section_height/2 + (slot_neck_depth + 2*overlap)/2 - overlap, 0])
          cube([slot_opening_width, slot_neck_depth + 2*overlap, length + 2*overlap], center=true);
        translate([0, -cross_section_height/2 + slot_neck_depth + (slot_depth - slot_neck_depth + 2*overlap)/2 - overlap, 0])
          cube([slot_inner_width, slot_depth - slot_neck_depth + 2*overlap, length + 2*overlap], center=true);
      }
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width/2 - corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([cross_section_width/2 - corner_hole_inset, -cross_section_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-cross_section_width/2 + corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-cross_section_width/2 + corner_hole_inset, -cross_section_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
        }
      }
    }
  }
}

// Extrusion Cross Section - complete geometry
module extrusion_cross_section() {
  color("Silver") {
    linear_extrude(height=wall_thickness, center=true) {
      square([cross_section_width, cross_section_height], center=true);
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("Silver") {
    translate([cross_section_width/4, cross_section_height/4, 0])
      cube([cross_section_width/2, cross_section_height/2, wall_thickness], center=true);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("Silver") {
    translate([-cross_section_width/4, -cross_section_height/4, 0])
      cube([cross_section_width/2, cross_section_height/2, wall_thickness], center=true);
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