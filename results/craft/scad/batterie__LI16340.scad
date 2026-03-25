// Parameters
height_mm = 35.2; //[17.6:70.4:0.1]
diameter_mm = 16.4; //[8.2:32.8:0.1]
radius_mm = 8.2; //[4.1:16.4:0.1]
positive_terminal_height_mm = 1.0; //[0.5:2.0:0.1]
positive_terminal_diameter_mm = 5.0; //[2.5:10.0:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
body_height_mm = 34.0; //[17.0:68.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Battery cell body
module cylindrical_cell_body() {
  color("DimGray") {
    translate([0, 0, 0])
      cylinder(r=radius_mm, h=body_height_mm, center=true, $fn=64);
  }
}

// Positive terminal button
module positive_terminal_button() {
  color("Silver") {
    translate([0, 0, body_height_mm/2 + positive_terminal_height_mm/2 - overlap_mm])
      cylinder(r=positive_terminal_diameter_mm/2, h=positive_terminal_height_mm, center=true, $fn=32);
  }
}

// Negative terminal flat end
module negative_terminal_flat_end() {
  color("Silver") {
    translate([0, 0, -body_height_mm/2 - negative_terminal_height_mm/2 + overlap_mm])
      cylinder(r=radius_mm, h=negative_terminal_height_mm, center=true, $fn=64);
  }
}

// Complete battery assembly
module battery() {
  union() {
    cylindrical_cell_body();
    positive_terminal_button();
    negative_terminal_flat_end();
  }
}

// Final assembly
module assembly() {
  battery();
}

assembly();