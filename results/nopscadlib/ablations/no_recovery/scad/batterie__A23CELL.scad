// Parameters
height_mm = 28.5; //[14.25:57:0.1]
diameter_mm = 10.3; //[5.15:20.6:0.1]
positive_terminal_height_mm = 1; //[0.5:2:0.1]
positive_terminal_diameter_mm = 4; //[2:8:0.1]
negative_terminal_height_mm = 0.3; //[0.15:0.6:0.05]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
overlap_mm = 0.8; //[0.2:2:0.1]
centered = 1; //[0:1:1]

// Battery - complete geometry
module battery() {
  union() {
    // Battery Cell Body
    color("DimGray") {
      translate([0, 0, 0])
        cylinder(h=height_mm, r=diameter_mm/2, center=true);
    }
    // Positive Terminal Cap
    color("Silver") {
      translate([0, 0, height_mm/2 + positive_terminal_height_mm/2 - overlap_mm])
        cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true);
    }
    // Negative Terminal Contact
    color("Silver") {
      translate([0, 0, -height_mm/2 - negative_terminal_height_mm/2 + overlap_mm])
        cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();