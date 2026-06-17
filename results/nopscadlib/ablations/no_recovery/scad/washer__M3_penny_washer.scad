// Parameters
inner_diameter = 3.0; //[1.5:6.0:0.1]
outer_diameter = 12.0; //[6.0:24.0:0.1]
thickness = 0.8; //[0.4:1.6:0.05]
eps = 0.6; //[0.2:2.0:0.1]

// Penny Washer - complete geometry
module penny_washer() {
  color("Silver") {
    difference() {
      // Outer ring
      cylinder(r=outer_diameter/2, h=thickness, center=true, $fn=64);
      // Inner hole
      cylinder(r=inner_diameter/2, h=thickness + 2*eps, center=true, $fn=64);
    }
  }
}

// Round Grommet Top - complete geometry
module round_grommet_top() {
  color("DimGray") {
    // Grommet top
    cylinder(r=outer_diameter/2, h=thickness, center=true, $fn=64);
  }
}

// Round Grommet Assembly - complete geometry
module round_grommet_assembly() {
  color("DimGray") {
    union() {
      penny_washer();
      round_grommet_top();
    }
  }
}

// Screw And Washer - complete geometry
module screw_and_washer() {
  color("Black") {
    union() {
      round_grommet_assembly();
      // Additional screw head or detail can be added here if needed
    }
  }
}

// Final Assembly
module assembly() {
  screw_and_washer();
}

assembly();