// Parameters
height_mm = 35.2; //[17.6:70.4:0.1]
diameter_mm = 16.4; //[8.2:32.8:0.1]
positive_terminal_height_mm = 1.0; //[0.5:2.0:0.1]
positive_terminal_diameter_mm = 5.0; //[2.5:10.0:0.1]
negative_terminal_recess_mm = 0.0; //[0.0:2.0:0.1]
connect_overlap_mm = 0.8; //[0.5:2.0:0.1]

// Battery - complete geometry
module battery() {
  color("Silver") {
    // Main body
    cylinder(h=height_mm, r=diameter_mm/2, center=true, $fn=64);
    
    // Positive terminal bump
    translate([0, 0, height_mm/2 - connect_overlap_mm])
      cylinder(h=positive_terminal_height_mm, r=positive_terminal_diameter_mm/2, center=true, $fn=32);
    
    // Negative terminal flat
    translate([0, 0, -height_mm/2 + connect_overlap_mm/2])
      cylinder(h=connect_overlap_mm, r=diameter_mm/2, center=true, $fn=64);
    
    // Negative terminal recess (if any)
    if (negative_terminal_recess_mm > 0) {
      difference() {
        cylinder(h=negative_terminal_recess_mm, r=diameter_mm/2, center=true, $fn=64);
        translate([0, 0, -negative_terminal_recess_mm/2])
          cylinder(h=negative_terminal_recess_mm, r=diameter_mm/2 - 1, center=true, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();