// Parameters
overall_height_mm = 44.5; //[22.25:89:0.1]
outer_diameter_mm = 10.5; //[5.25:21:0.1]
positive_terminal_diameter_mm = 5; //[2.5:10:0.1]
positive_terminal_height_mm = 1; //[0.5:2:0.05]
negative_terminal_diameter_mm = 10.5; //[5.25:21:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
body_fillet_radius_mm = 0.5; //[0.25:1:0.05]
terminal_overlap_mm = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Cylindrical body with filleted edges
    minkowski() {
      cylinder(h=overall_height_mm - 2*body_fillet_radius_mm, 
               r=outer_diameter_mm/2 - body_fillet_radius_mm, center=true);
      sphere(r=body_fillet_radius_mm);
    }
    
    // Positive terminal button
    translate([0, 0, overall_height_mm/2 - positive_terminal_height_mm/2 - terminal_overlap_mm])
      cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true);
    
    // Negative terminal flat end
    translate([0, 0, -overall_height_mm/2 + negative_terminal_height_mm/2 + terminal_overlap_mm])
      cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();