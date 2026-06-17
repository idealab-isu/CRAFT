// Parameters
height_mm = 50; //[25:100:0.1]
diameter_mm = 26.2; //[13.1:52.4:0.1]
positive_terminal_diameter_mm = 5; //[2.5:10:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.1]
negative_terminal_diameter_mm = 8; //[4:16:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
terminal_overlap_mm = 0.8; //[0.2:2:0.1]

// Battery - complete geometry
module battery() {
  union() {
    // Cylindrical cell body
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