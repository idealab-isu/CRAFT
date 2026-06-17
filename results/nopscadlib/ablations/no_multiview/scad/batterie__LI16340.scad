// Parameters
height_mm = 35.2; //[17.6:70.4:0.1]
diameter_mm = 16.4; //[8.2:32.8:0.1]
positive_terminal_diameter_mm = 5.5; //[2.75:11:0.1]
positive_terminal_height_mm = 1.2; //[0.6:2.4:0.1]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
negative_terminal_height_mm = 0.3; //[0.15:0.6:0.05]
body_fillet_radius_mm = 0.5; //[0.25:1:0.05]
terminal_overlap_mm = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Cylindrical cell body with filleted edges
    minkowski() {
      cylinder(r=diameter_mm/2 - body_fillet_radius_mm, h=height_mm - 2*body_fillet_radius_mm, center=true);
      sphere(r=body_fillet_radius_mm, center=true);
    }
    
    // Positive terminal button
    translate([0, 0, height_mm/2 - positive_terminal_height_mm/2 - terminal_overlap_mm])
      cylinder(r=positive_terminal_diameter_mm/2, h=positive_terminal_height_mm, center=true);
    
    // Negative terminal contact
    translate([0, 0, -height_mm/2 + negative_terminal_height_mm/2 + terminal_overlap_mm])
      cylinder(r=negative_terminal_diameter_mm/2, h=negative_terminal_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();