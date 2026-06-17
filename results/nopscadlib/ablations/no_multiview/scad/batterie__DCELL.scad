// Parameters
height_mm = 61.5; //[30.75:123:0.1]
diameter_mm = 34.2; //[17.1:68.4:0.1]
positive_terminal_diameter_mm = 10; //[5:20:0.1]
positive_terminal_height_mm = 1.5; //[0.75:3:0.1]
negative_terminal_diameter_mm = 12; //[6:24:0.1]
negative_terminal_height_mm = 0.5; //[0.25:1:0.05]
edge_fillet_radius_mm = 0.5; //[0.25:1:0.05]
connect_overlap_mm = 0.8; //[0.5:2:0.1]

// Battery Cell Body with Fillet
module battery_cell_body() {
  color("DimGray") {
    difference() {
      // Main cylindrical body
      cylinder(h=height_mm - 2*edge_fillet_radius_mm, r=diameter_mm/2 - edge_fillet_radius_mm, center=true, $fn=64);
      // Fillet effect using offset
      translate([0, 0, height_mm/2 - edge_fillet_radius_mm])
        sphere(r=edge_fillet_radius_mm, $fn=32);
      translate([0, 0, -height_mm/2 + edge_fillet_radius_mm])
        sphere(r=edge_fillet_radius_mm, $fn=32);
    }
  }
}

// Positive Terminal Cap
module positive_terminal_cap() {
  color("Silver") {
    translate([0, 0, height_mm/2 - positive_terminal_height_mm/2 - connect_overlap_mm])
      cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
  }
}

// Negative Terminal Contact
module negative_terminal_contact() {
  color("Silver") {
    translate([0, 0, -height_mm/2 + negative_terminal_height_mm/2 + connect_overlap_mm])
      cylinder(h=negative_terminal_height_mm, r=negative_terminal_diameter_mm/2, center=true, $fn=32);
  }
}

// Complete Battery Assembly
module battery() {
  union() {
    battery_cell_body();
    positive_terminal_cap();
    negative_terminal_contact();
  }
}

// Final Assembly
module assembly() {
  battery();
}

assembly();