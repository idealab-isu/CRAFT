// Parameters
overall_height_mm = 28.5; //[14.25:57:0.1]
outer_diameter_mm = 10.3; //[5.15:20.6:0.1]
positive_terminal_height_mm = 1; //[0.5:2:0.05]
positive_terminal_diameter_mm = 4.5; //[2.25:9:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
terminal_overlap_mm = 0.8; //[0.5:2:0.1]
body_height_mm = 27.3; //[13.65:54.6:0.1]

// Battery - complete geometry
module battery() {
  union() {
    // Cylindrical cell body
    color("DimGray") {
      translate([0, 0, 0])
        cylinder(h=body_height_mm, r=outer_diameter_mm/2, center=true, $fn=64);
    }
    // Positive terminal button
    color("Silver") {
      translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - terminal_overlap_mm])
        cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
    }
    // Negative terminal contact
    color("Silver") {
      translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + terminal_overlap_mm])
        cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();