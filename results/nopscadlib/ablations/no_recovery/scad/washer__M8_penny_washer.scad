// Parameters
inner_diameter_mm = 8.0; //[4.0:16.0:0.1]
outer_diameter_mm = 30.0; //[15.0:60.0:0.1]
thickness_mm = 1.5; //[0.75:3.0:0.05]
eps_mm = 0.8; //[0.5:2.0:0.1]

// Penny Washer - complete geometry
module penny_washer() {
  color("Silver") {
    difference() {
      // Outer cylinder
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true, $fn=64);
      // Inner hole
      cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
    }
  }
}

// Screw And Washer - placeholder geometry
module screw_and_washer() {
  color("DimGray") {
    // Placeholder for screw and washer
    translate([0, 0, thickness_mm/2 + 1]) {
      cylinder(r=outer_diameter_mm/4, h=thickness_mm, center=true, $fn=32);
    }
  }
}

// Round Grommet Top - complete geometry
module round_grommet_top() {
  color("Black") {
    // Grommet top
    translate([0, 0, thickness_mm]) {
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true, $fn=64);
    }
  }
}

// Round Grommet Assembly - complete geometry
module round_grommet_assembly() {
  color("Black") {
    // Grommet assembly
    translate([0, 0, thickness_mm * 2]) {
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  penny_washer();
  screw_and_washer();
  round_grommet_top();
  round_grommet_assembly();
}

assembly();