// Parameters
height_mm = 50.0; //[25.0:100.0:0.1]
diameter_mm = 26.2; //[13.1:52.4:0.1]
positive_terminal_diameter_mm = 10.0; //[5.0:20.0:0.1]
positive_terminal_height_mm = 1.6; //[0.8:3.2:0.1]
negative_terminal_diameter_mm = 18.0; //[9.0:26.2:0.1]
terminal_overlap_mm = 0.8; //[0.5:2.0:0.1]
negative_contact_thickness_mm = 0.6; //[0.3:1.5:0.1]

// Battery - complete geometry
module battery() {
  // Cell Body
  color([0.85, 0.85, 0.8]) { // Off-white for typical battery casing
    translate([0, 0, 0])
      cylinder(h=height_mm, r=diameter_mm/2, center=true, $fn=64);
  }
  
  // Positive Terminal
  color("Silver") { // Silver for metal contact
    translate([0, 0, height_mm/2 + positive_terminal_height_mm/2 - terminal_overlap_mm])
      cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
  }
  
  // Negative Terminal
  color("Silver") { // Silver for metal contact
    translate([0, 0, -height_mm/2 - negative_contact_thickness_mm/2 + terminal_overlap_mm])
      cylinder(h=negative_contact_thickness_mm, r=negative_terminal_diameter_mm/2, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();