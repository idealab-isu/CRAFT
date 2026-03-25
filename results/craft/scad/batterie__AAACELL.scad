// Parameters
overall_height_mm = 44.5; //[22.25:89:0.1]
outer_diameter_mm = 10.5; //[5.25:21:0.1]
body_diameter_mm = 10.5; //[5.25:21:0.1]
body_height_mm = 43.5; //[21.75:87:0.1]
positive_terminal_height_mm = 1; //[0.5:2:0.05]
positive_terminal_diameter_mm = 4.5; //[2.25:9:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
edge_fillet_radius_mm = 0.3; //[0.15:0.8:0.05]
terminal_overlap_mm = 0.8; //[0.5:2:0.1]
minkowski_sphere_radius_mm = 0.3; //[0.15:0.8:0.05]

// AAACELL - complete geometry
module AAACELL() {
  color([0.85, 0.85, 0.8]) {
    // Cylindrical cell body with edge fillet
    minkowski() {
      cylinder(r=body_diameter_mm/2 - minkowski_sphere_radius_mm, 
               h=body_height_mm - 2*minkowski_sphere_radius_mm, center=true);
      sphere(r=minkowski_sphere_radius_mm, center=true);
    }
    
    // Positive terminal button
    translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - terminal_overlap_mm])
      cylinder(r=positive_terminal_diameter_mm/2, h=positive_terminal_height_mm, center=true);
    
    // Negative terminal contact
    translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + terminal_overlap_mm])
      cylinder(r=negative_terminal_diameter_mm/2, h=negative_terminal_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  AAACELL();
}

assembly();