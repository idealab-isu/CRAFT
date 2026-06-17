// Parameters
inner_diameter = 8.0; //[4.0:16.0:0.1]
outer_diameter = 30.0; //[15.0:60.0:0.1]
thickness = 1.5; //[0.75:3.0:0.05]
hole_clearance = 0.2; //[0.0:0.6:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
grommet_lip_height = 0.8; //[0.4:2.0:0.1]
grommet_lip_radial = 1.5; //[0.8:4.0:0.1]

// Penny Washer - complete geometry
module penny_washer() {
  color("Silver") {
    difference() {
      // Washer body
      cylinder(r=outer_diameter/2, h=thickness, center=true);
      // Inner through-hole
      translate([0, 0, -overlap])
        cylinder(r=(inner_diameter + hole_clearance)/2, h=thickness + 2*overlap, center=true);
    }
  }
}

// Screw And Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw body (simplified as a cylinder for this example)
    translate([0, 0, thickness/2])
      cylinder(r=inner_diameter/4, h=thickness*2, center=true);
    // Washer
    penny_washer();
  }
}

// Round Grommet Top - complete geometry
module round_grommet_top() {
  color("Black") {
    // Grommet lip
    translate([0, 0, thickness/2 + grommet_lip_height/2 - overlap])
      cylinder(r=outer_diameter/2 + grommet_lip_radial, h=grommet_lip_height, center=true);
  }
}

// Round Grommet Assembly - complete geometry
module round_grommet_assembly() {
  union() {
    penny_washer();
    round_grommet_top();
  }
}

// Assembly
module assembly() {
  penny_washer();
  translate([0, 0, thickness]) screw_and_washer();
  translate([0, 0, thickness]) round_grommet_assembly();
}

assembly();