// Parameters
outer_width = 50.8; //[25.4:101.6:0.1]
outer_height = 38.1; //[19.05:76.2:0.1]
wall_thickness = 3; //[1.5:6:0.1]
length = 100; //[50:200:1]

// Box Section - complete geometry
module box_section() {
  color("Silver") {
    difference() {
      // Outer box
      cube([outer_width, outer_height, length], center=true);
      // Inner void
      translate([0, 0, 0])
        cube([outer_width - 2*wall_thickness, outer_height - 2*wall_thickness, length], center=true);
    }
  }
}

// Box Corner Profile Section - complete geometry
module box_corner_profile_section() {
  color("DimGray") {
    // Corner profile
    translate([-outer_width/2, -outer_height/2, -length/2])
      cube([wall_thickness, wall_thickness, length]);
  }
}

// Box Bezel Section - complete geometry
module box_bezel_section() {
  color("Black") {
    // Bezel
    translate([-outer_width/2, -outer_height/2, length/2])
      cube([outer_width, wall_thickness, wall_thickness]);
  }
}

// Box Corner Profile Sections - complete geometry
module box_corner_profile_sections() {
  color("DimGray") {
    // Corner profiles
    translate([outer_width/2 - wall_thickness, -outer_height/2, -length/2])
      cube([wall_thickness, wall_thickness, length]);
    translate([-outer_width/2, outer_height/2 - wall_thickness, -length/2])
      cube([wall_thickness, wall_thickness, length]);
    translate([outer_width/2 - wall_thickness, outer_height/2 - wall_thickness, -length/2])
      cube([wall_thickness, wall_thickness, length]);
  }
}

// Box Shelf Bracket Section - complete geometry
module box_shelf_bracket_section() {
  color("Silver") {
    // L-shaped bracket
    difference() {
      union() {
        // Vertical plate
        translate([-outer_width/2, -outer_height/2, -length/2])
          cube([wall_thickness, outer_height, 4]);
        // Horizontal plate
        translate([-outer_width/2, -outer_height/2, -length/2])
          cube([outer_width, wall_thickness, 4]);
      }
      // Mounting holes
      translate([-outer_width/2 + wall_thickness/2, -outer_height/2 + wall_thickness/2, -length/2 + 2])
        cylinder(d=2, h=5, center=true, $fn=16);
      translate([outer_width/2 - wall_thickness/2, -outer_height/2 + wall_thickness/2, -length/2 + 2])
        cylinder(d=2, h=5, center=true, $fn=16);
    }
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