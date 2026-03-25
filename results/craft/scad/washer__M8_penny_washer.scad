// Parameters
inner_hole_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 30; //[15:60:0.1]
thickness_mm = 1.5; //[0.75:3:0.05]

// M8 Penny Washer - complete geometry
module washer() {
  color("Silver") {
    difference() {
      // Outer cylinder
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true, $fn=64);
      // Inner hole
      cylinder(r=inner_hole_diameter_mm/2, h=thickness_mm*2, center=true, $fn=64);
    }
  }
}

// Penny Washer - identical to M8 Penny Washer for this example
module penny_washer() {
  washer();
}

// Screw And Washer - placeholder for custom geometry
module screw_and_washer() {
  color("DimGray") {
    // Placeholder geometry
    translate([0, 0, thickness_mm]) washer();
  }
}

// Round Grommet Assembly - placeholder for custom geometry
module round_grommet_assembly() {
  color("Black") {
    // Placeholder geometry
    translate([0, 0, thickness_mm*2]) washer();
  }
}

// Round Grommet Top - placeholder for custom geometry
module round_grommet_top() {
  color("Black") {
    // Placeholder geometry
    translate([0, 0, thickness_mm*3]) washer();
  }
}

// Final Assembly
module assembly() {
  washer();
  penny_washer();
  screw_and_washer();
  round_grommet_assembly();
  round_grommet_top();
}

assembly();