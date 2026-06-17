// Parameters
inner_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 12; //[6:24:0.1]
thickness_mm = 0.8; //[0.4:1.6:0.05]
eps_mm = 0.8; //[0.2:2:0.1]
grommet_top_height_mm = 0.8; //[0.4:2:0.05]
grommet_top_radial_mm = 1.2; //[0.6:3:0.1]
screw_shank_diameter_mm = 3; //[1.5:6:0.1]
screw_length_mm = 6; //[3:20:0.5]

// Penny Washer - complete geometry
module penny_washer() {
  color("Silver") {
    difference() {
      // Washer body
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
      // Inner through-hole
      translate([0, 0, 0])
        cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Round Grommet Top - complete geometry
module round_grommet_top() {
  color("DimGray") {
    difference() {
      // Outer grommet
      translate([0, 0, thickness_mm/2 + grommet_top_height_mm/2 - eps_mm])
        cylinder(r=outer_diameter_mm/2 + grommet_top_radial_mm, h=grommet_top_height_mm, center=true);
      // Inner hole
      translate([0, 0, thickness_mm/2 + grommet_top_height_mm/2 - eps_mm])
        cylinder(r=inner_diameter_mm/2, h=grommet_top_height_mm + 2*eps_mm, center=true);
    }
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
    union() {
      round_grommet_assembly();
      // Screw shank
      translate([0, 0, 0])
        cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
    }
  }
}

// Final Assembly
module assembly() {
  screw_and_washer();
}

assembly();