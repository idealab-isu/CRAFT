// Parameters
outer_width = 20; //[10:40:1]
outer_height = 20; //[10:40:1]
wall_thickness = 2; //[1:6:0.5]
length = 100; //[20:400:1]
center = 1; //[0:1:1]
corner_fillet_radius = 0; //[0:3:0.5]
overlap = 1; //[0.5:2:0.5]

// Box Section - Primary Component
module box_section() {
  color("Silver") {
    difference() {
      cube([outer_width, outer_height, length], center=true);
      translate([0, 0, 0])
        cube([outer_width - 2*wall_thickness, outer_height - 2*wall_thickness, length + 2*overlap], center=true);
    }
  }
}

// Box Corner Profile Section - Secondary Component
module box_corner_profile_section() {
  color("DimGray") {
    translate([outer_width/2 - wall_thickness/2, outer_height/2 - wall_thickness/2, 0])
      cube([wall_thickness, wall_thickness, length], center=true);
  }
}

// Box Bezel Section - Secondary Component
module box_bezel_section() {
  color("DimGray") {
    translate([0, 0, length/2 - wall_thickness/2])
      cube([outer_width, outer_height, wall_thickness], center=true);
  }
}

// Box Corner Profile Sections - Secondary Component
module box_corner_profile_sections() {
  color("DimGray") {
    translate([-outer_width/2 + wall_thickness/2, -outer_height/2 + wall_thickness/2, 0])
      cube([wall_thickness, wall_thickness, length], center=true);
  }
}

// Box Shelf Bracket Section - Secondary Component
module box_shelf_bracket_section() {
  color("Silver") {
    translate([0, outer_height/2 - wall_thickness/2, -length/2 + wall_thickness/2])
      cube([outer_width/2, wall_thickness, wall_thickness], center=true);
  }
}

// Assembly
module assembly() {
  box_section();
  box_corner_profile_section();
  box_bezel_section();
  box_corner_profile_sections();
  box_shelf_bracket_section();
}

assembly();