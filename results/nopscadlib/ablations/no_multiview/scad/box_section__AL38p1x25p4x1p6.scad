// Parameters
outer_width_mm = 38.1; //[19.05:76.2:0.1]
outer_height_mm = 25.4; //[12.7:50.8:0.1]
wall_thickness_mm = 1.6; //[0.8:3.2:0.1]
length_mm = 100; //[50:200:1]
overlap_mm = 1; //[0.5:2:0.1]

// Box Section - complete geometry
module box_section() {
  color("Silver") {
    difference() {
      // Outer box
      cube([outer_width_mm, outer_height_mm, length_mm], center=true);
      // Inner void
      translate([0, 0, 0])
        cube([outer_width_mm - 2*wall_thickness_mm, 
              outer_height_mm - 2*wall_thickness_mm, 
              length_mm + 2*overlap_mm], center=true);
    }
  }
}

// Box Corner Profile Section - placeholder geometry
module box_corner_profile_section() {
  color("DimGray") {
    // Example corner profile
    translate([-outer_width_mm/2, -outer_height_mm/2, 0])
      cube([5, 5, length_mm], center=false);
  }
}

// Box Bezel Section - placeholder geometry
module box_bezel_section() {
  color("Black") {
    // Example bezel
    translate([-outer_width_mm/2, -outer_height_mm/2, length_mm/2])
      cube([outer_width_mm, 5, 5], center=false);
  }
}

// Box Corner Profile Sections - placeholder geometry
module box_corner_profile_sections() {
  color("DimGray") {
    // Example corner profiles
    translate([outer_width_mm/2 - 5, outer_height_mm/2 - 5, 0])
      cube([5, 5, length_mm], center=false);
    translate([-outer_width_mm/2, outer_height_mm/2 - 5, 0])
      cube([5, 5, length_mm], center=false);
  }
}

// Box Shelf Bracket Section - complete geometry
module box_shelf_bracket_section() {
  color("Silver") {
    // L-shaped bracket
    difference() {
      union() {
        // Vertical plate
        translate([-outer_width_mm/2, -outer_height_mm/2, 0])
          cube([5, outer_height_mm, 4], center=false);
        // Horizontal plate
        translate([-outer_width_mm/2, -outer_height_mm/2, 0])
          cube([outer_width_mm, 5, 4], center=false);
      }
      // Mounting holes
      translate([-outer_width_mm/2 + 2.5, -outer_height_mm/2 + 2.5, 2])
        cylinder(r=1.5, h=5, center=true, $fn=16);
      translate([outer_width_mm/2 - 2.5, -outer_height_mm/2 + 2.5, 2])
        cylinder(r=1.5, h=5, center=true, $fn=16);
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