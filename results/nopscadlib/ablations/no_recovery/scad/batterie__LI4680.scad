// Parameters
height_mm = 80.2; //[40.1:160.4:0.1]
diameter_mm = 46.2; //[23.1:92.4:0.1]
body_diameter_mm = 46.2; //[23.1:92.4:0.1]
body_height_mm = 80.2; //[40.1:160.4:0.1]
positive_terminal_diameter_mm = 12; //[6:24:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.05]
negative_terminal_diameter_mm = 18; //[9:36:0.1]
negative_terminal_height_mm = 0.3; //[0.15:0.6:0.01]
terminal_overlap_mm = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  union() {
    // Main cylindrical body
    color("DimGray") {
      translate([0, 0, 0])
        cylinder(r=body_diameter_mm/2, h=body_height_mm, center=true, $fn=64);
    }
    // Positive terminal button
    color("Silver") {
      translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - terminal_overlap_mm])
        cylinder(r=positive_terminal_diameter_mm/2, h=positive_terminal_height_mm, center=true, $fn=32);
    }
    // Negative terminal contact
    color("Silver") {
      translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + terminal_overlap_mm])
        cylinder(r=negative_terminal_diameter_mm/2, h=negative_terminal_height_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();