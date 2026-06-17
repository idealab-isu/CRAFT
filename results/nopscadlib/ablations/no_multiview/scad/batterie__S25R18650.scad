// Parameters
height_mm = 65; //[32.5:130:0.1]
diameter_mm = 18.3; //[9.15:36.6:0.1]
body_diameter_mm = 18.3; //[9.15:36.6:0.1]
body_height_mm = 63.5; //[31.75:127:0.1]
positive_terminal_diameter_mm = 5.5; //[2.75:11:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.1]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
overlap_mm = 0.8; //[0.2:2:0.1]

// Battery - complete geometry
module battery() {
  union() {
    // Main cylindrical body
    color("DimGray") {
      translate([0, 0, 0])
        cylinder(h=body_height_mm, r=body_diameter_mm/2, center=true, $fn=64);
    }
    // Positive terminal button
    color("Silver") {
      translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - overlap_mm])
        cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
    }
    // Negative terminal contact
    color("Silver") {
      translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + overlap_mm])
        cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();