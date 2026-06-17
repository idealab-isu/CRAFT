// Parameters
height_mm = 35.2; //[17.6:70.4:0.1]
diameter_mm = 16.4; //[8.2:32.8:0.1]
positive_terminal_diameter_mm = 5.5; //[2.75:11:0.1]
positive_terminal_height_mm = 1.2; //[0.6:2.4:0.1]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
negative_terminal_height_mm = 0.3; //[0.15:0.6:0.05]
terminal_overlap_mm = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  union() {
    // Main cylindrical body
    color("DimGray") {
      translate([0, 0, 0])
        cylinder(h=height_mm, r=diameter_mm/2, center=true, $fn=64);
    }
    // Positive terminal button
    color("Silver") {
      translate([0, 0, height_mm/2 + positive_terminal_height_mm/2 - terminal_overlap_mm])
        cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
    }
    // Negative terminal contact
    color("Silver") {
      translate([0, 0, -height_mm/2 - negative_terminal_height_mm/2 + terminal_overlap_mm])
        cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();