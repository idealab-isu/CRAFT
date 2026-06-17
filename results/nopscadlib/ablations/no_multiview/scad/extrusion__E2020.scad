// Parameters
cross_section_width = 20; //[10:40:0.5]
cross_section_height = 20; //[10:40:0.5]
length = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 2; //[1:4:0.25]
slot_opening_width = 6; //[4:10:0.25]
slot_depth = 6; //[3:10:0.25]
slot_cavity_width = 10; //[6:14:0.25]
slot_cavity_depth = 3; //[1.5:6:0.25]
center_bore_diameter = 5; //[3:10:0.25]
corner_hole_diameter = 4.2; //[0:8:0.1]
corner_hole_inset = 5; //[3:8:0.25]
overlap = 1; //[0.5:2:0.25]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main extrusion body
      cube([cross_section_width, cross_section_height, length], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width/2 - (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_opening_width, length + 2*overlap], center=true);
        translate([cross_section_width/2 - slot_depth + slot_cavity_depth/2 - overlap/2, 0, 0])
          cube([slot_cavity_depth + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([-(cross_section_width/2 - (slot_depth + overlap)/2), 0, 0])
          cube([slot_depth + overlap, slot_opening_width, length + 2*overlap], center=true);
        translate([-(cross_section_width/2 - slot_depth + slot_cavity_depth/2 - overlap/2), 0, 0])
          cube([slot_cavity_depth + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([0, cross_section_height/2 - (slot_depth + overlap)/2, 0])
          cube([slot_opening_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, cross_section_height/2 - slot_depth + slot_cavity_depth/2 - overlap/2, 0])
          cube([slot_cavity_width, slot_cavity_depth + overlap, length + 2*overlap], center=true);
        translate([0, -(cross_section_height/2 - (slot_depth + overlap)/2), 0])
          cube([slot_opening_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, -(cross_section_height/2 - slot_depth + slot_cavity_depth/2 - overlap/2), 0])
          cube([slot_cavity_width, slot_cavity_depth + overlap, length + 2*overlap], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width/2 - corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-(cross_section_width/2 - corner_hole_inset), cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-(cross_section_width/2 - corner_hole_inset), -(cross_section_height/2 - corner_hole_inset), 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([cross_section_width/2 - corner_hole_inset, -(cross_section_height/2 - corner_hole_inset), 0])
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
      // Main extrusion body
      cube([cross_section_width, cross_section_height, length], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width/2 - (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_opening_width, length + 2*overlap], center=true);
        translate([cross_section_width/2 - slot_depth + slot_cavity_depth/2 - overlap/2, 0, 0])
          cube([slot_cavity_depth + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([-(cross_section_width/2 - (slot_depth + overlap)/2), 0, 0])
          cube([slot_depth + overlap, slot_opening_width, length + 2*overlap], center=true);
        translate([-(cross_section_width/2 - slot_depth + slot_cavity_depth/2 - overlap/2), 0, 0])
          cube([slot_cavity_depth + overlap, slot_cavity_width, length + 2*overlap], center=true);
        translate([0, cross_section_height/2 - (slot_depth + overlap)/2, 0])
          cube([slot_opening_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, cross_section_height/2 - slot_depth + slot_cavity_depth/2 - overlap/2, 0])
          cube([slot_cavity_width, slot_cavity_depth + overlap, length + 2*overlap], center=true);
        translate([0, -(cross_section_height/2 - (slot_depth + overlap)/2), 0])
          cube([slot_opening_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, -(cross_section_height/2 - slot_depth + slot_cavity_depth/2 - overlap/2), 0])
          cube([slot_cavity_width, slot_cavity_depth + overlap, length + 2*overlap], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width/2 - corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-(cross_section_width/2 - corner_hole_inset), cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-(cross_section_width/2 - corner_hole_inset), -(cross_section_height/2 - corner_hole_inset), 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([cross_section_width/2 - corner_hole_inset, -(cross_section_height/2 - corner_hole_inset), 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - detailed geometry
module box_corner_profile_section() {
  color("Black") {
    cube([cross_section_width/2 - wall_thickness, cross_section_height/2 - wall_thickness, length], center=true);
  }
}

// Box Corner Profile Sections - detailed geometry
module box_corner_profile_sections() {
  color("Black") {
    union() {
      box_corner_profile_section();
      mirror([1, 0, 0]) box_corner_profile_section();
      mirror([0, 1, 0]) box_corner_profile_section();
      mirror([1, 1, 0]) box_corner_profile_section();
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