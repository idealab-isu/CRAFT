// Parameters
inner_diameter = 6; //[3:12:0.1]
outer_diameter = 26; //[13:52:0.1]
thickness = 1.5; //[0.75:3:0.05]
eps = 0.8; //[0.2:2:0.1]
grommet_lip_thickness = 0.8; //[0.4:2:0.1]
grommet_lip_radial = 2; //[1:6:0.1]

// Penny Washer - complete geometry
module penny_washer() {
  color("Silver") {
    difference() {
      // Washer body
      cylinder(r=outer_diameter/2, h=thickness, center=true);
      // Inner through-hole
      translate([0, 0, -eps])
        cylinder(r=inner_diameter/2, h=thickness + 2*eps, center=true);
    }
  }
}

// Round Grommet Top - complete geometry
module round_grommet_top() {
  color("DimGray") {
    translate([0, 0, thickness/2 + grommet_lip_thickness/2 - eps])
      cylinder(r=outer_diameter/2 + grommet_lip_radial, h=grommet_lip_thickness, center=true);
  }
}

// Round Grommet Assembly - complete geometry
module round_grommet_assembly() {
  union() {
    penny_washer();
    round_grommet_top();
  }
}

// Screw And Washer - complete geometry
module screw_and_washer() {
  color("Black") {
    // Placeholder for screw geometry
    translate([0, 0, thickness/2 + 5])
      cylinder(r=inner_diameter/4, h=10, center=true);
    // Washer
    penny_washer();
  }
}

// Assembly
module assembly() {
  round_grommet_assembly();
  translate([0, 0, thickness/2 + 5])
    screw_and_washer();
}

assembly();