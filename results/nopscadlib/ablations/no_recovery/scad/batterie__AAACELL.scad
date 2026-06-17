// Parameters
overall_height_mm = 44.5; //[22.25:89:0.1]
outer_diameter_mm = 10.5; //[5.25:21:0.1]
positive_terminal_diameter_mm = 4.5; //[2.25:9:0.1]
positive_terminal_height_mm = 1; //[0.5:2:0.05]
negative_terminal_recess_mm = 0; //[0:1.5:0.1]
edge_fillet_radius_mm = 0.3; //[0:1:0.05]
connection_overlap_mm = 0.8; //[0.2:2:0.1]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Main cylindrical body
    translate([0, 0, -positive_terminal_height_mm/2])
      cylinder(h=overall_height_mm - positive_terminal_height_mm, r=outer_diameter_mm/2, center=true, $fn=64);

    // Positive terminal button
    translate([0, 0, (overall_height_mm - positive_terminal_height_mm)/2 - positive_terminal_height_mm/2 - connection_overlap_mm/2])
      cylinder(h=positive_terminal_height_mm + connection_overlap_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=64);

    // Negative terminal face
    translate([0, 0, -(overall_height_mm - positive_terminal_height_mm)/2 - positive_terminal_height_mm/2 + (edge_fillet_radius_mm*2 + connection_overlap_mm)/2 - connection_overlap_mm])
      cylinder(h=edge_fillet_radius_mm*2 + connection_overlap_mm, r=outer_diameter_mm/2, center=true, $fn=64);

    // Negative terminal recess (if any)
    if (negative_terminal_recess_mm > 0) {
      difference() {
        translate([0, 0, -overall_height_mm/2 + negative_terminal_recess_mm/2])
          cylinder(h=negative_terminal_recess_mm, r=outer_diameter_mm/2 - edge_fillet_radius_mm, center=true, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();