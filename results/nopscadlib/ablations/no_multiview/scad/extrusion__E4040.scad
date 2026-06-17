// Parameters
cross_section_width = 40; //[20:80:1]
cross_section_height = 40; //[20:80:1]
length = 100; //[50:200:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 3; //[1.5:6:0.5]
slot_width = 8; //[4:14:0.5]
slot_depth = 10; //[6:18:0.5]
center_bore_diameter = 8; //[4:16:0.5]
corner_hole_diameter = 5; //[2:10:0.5]
corner_hole_inset = 10; //[6:16:0.5]
overlap = 1; //[0.5:2:0.5]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Main body
      cube([cross_section_width, cross_section_height, length], center=true);
      
      // T-slot channels
      union() {
        translate([cross_section_width/2 - (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_width, length + 2*overlap], center=true);
        translate([-cross_section_width/2 + (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_width, length + 2*overlap], center=true);
        translate([0, cross_section_height/2 - (slot_depth + overlap)/2, 0])
          cube([slot_width, slot_depth + overlap, length + 2*overlap], center=true);
        translate([0, -cross_section_height/2 + (slot_depth + overlap)/2, 0])
          cube([slot_width, slot_depth + overlap, length + 2*overlap], center=true);
      }
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter/2, h=length + 2*overlap, center=true);
      
      // Corner holes
      if (cornerHole) {
        union() {
          translate([cross_section_width/2 - corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-cross_section_width/2 + corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([cross_section_width/2 - corner_hole_inset, -cross_section_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
          translate([-cross_section_width/2 + corner_hole_inset, -cross_section_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + 2*overlap, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("DimGray") {
    union() {
      translate([cross_section_width/2 - wall_thickness/2, cross_section_height/2 - wall_thickness/2, 0])
        cube([wall_thickness, wall_thickness, length], center=true);
      translate([-cross_section_width/2 + wall_thickness/2, cross_section_height/2 - wall_thickness/2, 0])
        cube([wall_thickness, wall_thickness, length], center=true);
      translate([cross_section_width/2 - wall_thickness/2, -cross_section_height/2 + wall_thickness/2, 0])
        cube([wall_thickness, wall_thickness, length], center=true);
      translate([-cross_section_width/2 + wall_thickness/2, -cross_section_height/2 + wall_thickness/2, 0])
        cube([wall_thickness, wall_thickness, length], center=true);
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  box_corner_profile_section();
}

assembly();