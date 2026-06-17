// Parameters
height_mm = 80.2; //[40.1:160.4:0.1]
diameter_mm = 46.2; //[23.1:92.4:0.1]
positive_terminal_diameter_mm = 12; //[6:24:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.05]
negative_terminal_diameter_mm = 10; //[5:20:0.1]
negative_terminal_height_mm = 0.3; //[0.15:0.6:0.05]
edge_fillet_radius_mm = 0.5; //[0.25:1:0.05]
terminal_overlap_mm = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Cylindrical cell body with edge fillet
    minkowski() {
      cylinder(
        r=diameter_mm/2 - edge_fillet_radius_mm, 
        h=height_mm - 2*edge_fillet_radius_mm, 
        center=true
      );
      sphere(r=edge_fillet_radius_mm, center=true);
    }
    
    // Positive terminal button
    translate([0, 0, height_mm/2 - positive_terminal_height_mm/2 - terminal_overlap_mm])
      cylinder(
        r=positive_terminal_diameter_mm/2, 
        h=positive_terminal_height_mm, 
        center=true
      );
    
    // Negative terminal contact
    translate([0, 0, -height_mm/2 + negative_terminal_height_mm/2 + terminal_overlap_mm])
      cylinder(
        r=negative_terminal_diameter_mm/2, 
        h=negative_terminal_height_mm, 
        center=true
      );
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();