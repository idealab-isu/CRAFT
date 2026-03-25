// Parameters
height_mm = 65.0; //[32.5:130.0:0.1]
diameter_mm = 18.3; //[9.15:36.6:0.1]
positive_terminal_diameter_mm = 5.5; //[2.75:11.0:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3.0:0.1]
negative_terminal_diameter_mm = 10.0; //[5.0:20.0:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
terminal_overlap_mm = 0.8; //[0.5:2.0:0.1]

// Battery cell body
module battery_cell_body() {
  color("DimGray") {
    cylinder(h=height_mm, r=diameter_mm/2, center=true, $fn=64);
  }
}

// Positive terminal button
module positive_terminal_button() {
  color("Silver") {
    translate([0, 0, height_mm/2 + positive_terminal_height_mm/2 - terminal_overlap_mm])
      cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
  }
}

// Negative terminal contact
module negative_terminal_contact() {
  color("Silver") {
    translate([0, 0, -height_mm/2 - negative_terminal_height_mm/2 + terminal_overlap_mm])
      cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true, $fn=32);
  }
}

// Complete battery assembly
module battery() {
  union() {
    battery_cell_body();
    positive_terminal_button();
    negative_terminal_contact();
  }
}

// Final assembly
module assembly() {
  battery();
}

assembly();