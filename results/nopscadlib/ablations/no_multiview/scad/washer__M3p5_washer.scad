// Parameters
inner_diameter_mm = 3.5; //[1.75:7:0.05]
outer_diameter_mm = 8; //[4:16:0.1]
thickness_mm = 0.5; //[0.25:1:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Derived parameters
inner_radius_mm = inner_diameter_mm / 2; //[0.875:3.5:0.025]
outer_radius_mm = outer_diameter_mm / 2; //[2:8:0.05]

// Washer geometry
module washer() {
  difference() {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
    cylinder(r=inner_radius_mm, h=thickness_mm + 2 * eps_mm, center=true);
  }
}

// Round Grommet Top - Custom geometry
module round_grommet_top() {
  color("Silver") {
    translate([0, 0, thickness_mm]) {
      cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
      translate([0, 0, thickness_mm / 2]) {
        cylinder(r=outer_radius_mm * 0.8, h=thickness_mm / 2, center=true);
      }
    }
  }
}

// Round Grommet Assembly - Custom geometry
module round_grommet_assembly() {
  color("DimGray") {
    translate([0, 0, 2 * thickness_mm]) {
      cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
      translate([0, 0, thickness_mm / 2]) {
        cylinder(r=outer_radius_mm * 0.7, h=thickness_mm / 2, center=true);
      }
    }
  }
}

// Nut And Washer - Custom geometry
module nut_and_washer() {
  color("Black") {
    translate([0, 0, 3 * thickness_mm]) {
      cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
      translate([0, 0, thickness_mm / 2]) {
        cylinder(r=outer_radius_mm * 0.6, h=thickness_mm / 2, center=true);
      }
    }
  }
}

// Screw And Washer - Custom geometry
module screw_and_washer() {
  color("Silver") {
    translate([0, 0, 4 * thickness_mm]) {
      cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
      translate([0, 0, thickness_mm / 2]) {
        cylinder(r=outer_radius_mm * 0.5, h=thickness_mm / 2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  washer();
  round_grommet_top();
  round_grommet_assembly();
  nut_and_washer();
  screw_and_washer();
}

assembly();