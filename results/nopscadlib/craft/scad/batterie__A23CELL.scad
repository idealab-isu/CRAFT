// Parameters
overall_height_mm = 28.5; //[14.25:57:0.1]
outer_diameter_mm = 10.3; //[5.15:20.6:0.1]
body_height_mm = 27.8; //[13.9:55.6:0.1]
positive_terminal_height_mm = 0.7; //[0.35:1.4:0.05]
positive_terminal_diameter_mm = 4.5; //[2.25:9:0.1]
negative_terminal_height_mm = 0; //[0:1:0.05]
connection_overlap_mm = 0.8; //[0.5:2:0.1]

// Battery - complete geometry
module battery() {
  union() {
    // Cylindrical cell body
    color("Silver") {
      translate([0, 0, -(overall_height_mm/2) + (body_height_mm/2)])
        cylinder(h=body_height_mm, r=outer_diameter_mm/2, center=true, $fn=64);
    }
    
    // Positive terminal button
    color("Gold") {
      translate([0, 0, (overall_height_mm/2) - (positive_terminal_height_mm/2) - connection_overlap_mm])
        cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=64);
    }
    
    // Negative terminal flat end
    color("Silver") {
      translate([0, 0, -(overall_height_mm/2) + (connection_overlap_mm/2)])
        cylinder(h=connection_overlap_mm, r=outer_diameter_mm/2, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();