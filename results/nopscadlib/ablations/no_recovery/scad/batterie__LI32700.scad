// Parameters
height_mm = 70.2; //[35.1:140.4:0.1]
diameter_mm = 32.4; //[16.2:64.8:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.1]
positive_terminal_diameter_mm = 10; //[5:20:0.1]
negative_terminal_height_mm = 0.5; //[0.25:1:0.05]
negative_terminal_diameter_mm = 12; //[6:24:0.1]
terminal_overlap_mm = 1; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Cylindrical cell body
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