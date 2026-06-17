// Parameters
cross_section_width = 20.0; //[10.0:40.0:0.5]
cross_section_height = 20.0; //[10.0:40.0:0.5]
length = 100.0; //[50.0:200.0:1]
center = 1; //[0:1:1]
cornerHole = 1; //[0:1:1]
wall_thickness = 2.0; //[1.0:4.0:0.25]
slot_opening = 6.0; //[4.0:8.0:0.25]
slot_depth = 6.0; //[4.0:9.0:0.25]
center_bore_diameter = 5.0; //[3.0:8.0:0.25]
web_thickness = 2.0; //[1.0:4.0:0.25]
corner_hole_diameter = 3.0; //[2.0:5.0:0.25]
corner_hole_inset = 5.0; //[3.0:8.0:0.25]
overlap = 1.0; //[0.5:2.0:0.25]

// Extrusion Cross Section
module extrusion_cross_section() {
  color("Silver") {
    difference() {
      cube([cross_section_width, cross_section_height, length], center=true);
      union() {
        translate([cross_section_width/2 - (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_opening, length + overlap], center=true);
        translate([-cross_section_width/2 + (slot_depth + overlap)/2, 0, 0])
          cube([slot_depth + overlap, slot_opening, length + overlap], center=true);
        translate([0, cross_section_height/2 - (slot_depth + overlap)/2, 0])
          cube([slot_opening, slot_depth + overlap, length + overlap], center=true);
        translate([0, -cross_section_height/2 + (slot_depth + overlap)/2, 0])
          cube([slot_opening, slot_depth + overlap, length + overlap], center=true);
      }
      union() {
        cylinder(r=center_bore_diameter/2, h=length + overlap, center=true);
        cube([cross_section_width - 2*wall_thickness, web_thickness, length], center=true);
        cube([web_thickness, cross_section_height - 2*wall_thickness, length], center=true);
      }
      if (cornerHole) {
        union() {
          translate([cross_section_width/2 - corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + overlap, center=true);
          translate([-cross_section_width/2 + corner_hole_inset, cross_section_height/2 - corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + overlap, center=true);
          translate([-cross_section_width/2 + corner_hole_inset, -cross_section_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + overlap, center=true);
          translate([cross_section_width/2 - corner_hole_inset, -cross_section_height/2 + corner_hole_inset, 0])
            cylinder(r=corner_hole_diameter/2, h=length + overlap, center=true);
        }
      }
    }
  }
}

// Box Corner Profile Section
module box_corner_profile_section() {
  color("Silver") {
    union() {
      translate([cross_section_width/2 - wall_thickness/2, cross_section_height/2 - wall_thickness/2, 0])
        cube([wall_thickness, wall_thickness, length], center=true);
      translate([-cross_section_width/2 + wall_thickness/2, cross_section_height/2 - wall_thickness/2, 0])
        cube([wall_thickness, wall_thickness, length], center=true);
      translate([-cross_section_width/2 + wall_thickness/2, -cross_section_height/2 + wall_thickness/2, 0])
        cube([wall_thickness, wall_thickness, length], center=true);
      translate([cross_section_width/2 - wall_thickness/2, -cross_section_height/2 + wall_thickness/2, 0])
        cube([wall_thickness, wall_thickness, length], center=true);
    }
  }
}

// Box Corner Profile Sections
module box_corner_profile_sections() {
  box_corner_profile_section();
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