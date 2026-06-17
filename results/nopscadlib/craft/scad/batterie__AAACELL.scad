// Parameters
height_mm = 44.5; //[22.25:89:0.1]
diameter_mm = 10.5; //[5.25:21:0.1]
body_diameter_mm = 10.5; //[5.25:21:0.1]
body_height_mm = 44.5; //[22.25:89:0.1]
positive_terminal_diameter_mm = 4.5; //[2.25:9:0.1]
positive_terminal_height_mm = 1; //[0.5:2:0.05]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
terminal_edge_radius_mm = 0.5; //[0.25:1:0.05]
connect_overlap_mm = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Main cylindrical body
    cylinder(h=body_height_mm, r=body_diameter_mm/2, center=true, $fn=64);
    
    // Positive terminal button
    translate([0, 0, body_height_mm/2 - positive_terminal_height_mm/2 + connect_overlap_mm]) {
      cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
    }
    
    // Negative terminal flat contact
    translate([0, 0, -body_height_mm/2 + negative_terminal_height_mm/2 - connect_overlap_mm]) {
      cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();