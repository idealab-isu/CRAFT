// Parameters
height_mm = 61.5; //[30.75:123:0.1]
diameter_mm = 34.2; //[17.1:68.4:0.1]
positive_terminal_diameter_mm = 10; //[5:20:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.1]
negative_terminal_diameter_mm = 12; //[6:24:0.1]
negative_terminal_height_mm = 0.5; //[0.25:1:0.05]
terminal_overlap_mm = 1; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Main cell cylinder
    cylinder(h=height_mm, r=diameter_mm/2, center=true, $fn=64);
    
    // Positive terminal button
    translate([0, 0, height_mm/2 + positive_terminal_height_mm/2 - terminal_overlap_mm])
      cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
    
    // Negative terminal contact
    translate([0, 0, -height_mm/2 - negative_terminal_height_mm/2 + terminal_overlap_mm])
      cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();