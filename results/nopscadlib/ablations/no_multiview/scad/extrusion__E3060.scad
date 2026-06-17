// Parameters
cross_section_width_mm = 30; //[15:60:1]
cross_section_height_mm = 60; //[30:120:1]
length_mm = 100; //[50:200:1]

// Extrusion - complete geometry
module extrusion() {
  color("Silver") {
    // Main body
    cube([cross_section_width_mm, cross_section_height_mm, length_mm], center=true);
  }
}

// Extrusion Cross Section - detailed geometry
module extrusion_cross_section() {
  color("DimGray") {
    // Cross section with corner holes
    difference() {
      cube([cross_section_width_mm, cross_section_height_mm, 5], center=true);
      for (x = [-cross_section_width_mm/2 + 5, cross_section_width_mm/2 - 5])
        for (y = [-cross_section_height_mm/2 + 5, cross_section_height_mm/2 - 5])
          translate([x, y, 0]) cylinder(d=4, h=10, center=true, $fn=16);
    }
  }
}

// Box Corner Profile Section - detailed geometry
module box_corner_profile_section() {
  color("Black") {
    // Corner profile with a hole
    difference() {
      cube([10, 10, length_mm], center=true);
      translate([0, 0, 0]) cylinder(d=3, h=length_mm + 2, center=true, $fn=16);
    }
  }
}

// Box Corner Profile Sections - detailed geometry
module box_corner_profile_sections() {
  color("Black") {
    // Four corner profiles
    for (x = [-cross_section_width_mm/2 + 5, cross_section_width_mm/2 - 5])
      for (y = [-cross_section_height_mm/2 + 5, cross_section_height_mm/2 - 5])
        translate([x, y, 0]) box_corner_profile_section();
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, length_mm/2 + 2.5]) extrusion_cross_section();
  box_corner_profile_sections();
}

assembly();