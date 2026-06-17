// Parameters
inner_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 14.0; //[7.0:28.0:0.1]
thickness_mm = 0.8; //[0.4:1.6:0.05]
eps_mm = 0.6; //[0.2:2.0:0.1]

// Penny Washer - complete geometry
module penny_washer() {
  color("Silver") {
    difference() {
      // Outer ring
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true, $fn=64);
      // Inner hole
      cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
    }
  }
}

// Round Grommet Top - complete geometry
module round_grommet_top() {
  color("DimGray") {
    difference() {
      // Outer ring
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true, $fn=64);
      // Inner hole
      cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
    }
  }
}

// Round Grommet Assembly - complete geometry
module round_grommet_assembly() {
  color("DimGray") {
    difference() {
      // Outer ring
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true, $fn=64);
      // Inner hole
      cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  union() {
    penny_washer();
    round_grommet_assembly();
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, thickness_mm]) round_grommet_top();
}

assembly();