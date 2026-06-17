// Parameters
inner_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 7; //[3.5:14:0.1]
thickness_mm = 0.5; //[0.25:1:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Washer - basic geometry
module washer_body() {
  color("Silver") difference() {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    cylinder(r=inner_diameter_mm/2, h=thickness_mm + eps_mm, center=true);
  }
}

// Round Grommet Top - detailed geometry
module round_grommet_top() {
  color("DimGray") {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
  }
}

// Round Grommet Assembly - detailed geometry
module round_grommet_assembly() {
  color("DimGray") {
    union() {
      washer_body();
      round_grommet_top();
    }
  }
}

// Nut And Washer - detailed geometry
module nut_and_washer() {
  color("Black") {
    union() {
      washer_body();
      translate([0, 0, thickness_mm/2]) cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    }
  }
}

// Screw And Washer - detailed geometry
module screw_and_washer() {
  color("Black") {
    union() {
      washer_body();
      translate([0, 0, thickness_mm/2]) cylinder(r=inner_diameter_mm/2, h=thickness_mm, center=true);
    }
  }
}

// Assembly - combines all parts
module assembly() {
  translate([0, 0, 0]) washer_body();
  translate([0, 0, thickness_mm]) round_grommet_top();
  translate([0, 0, thickness_mm * 2]) nut_and_washer();
  translate([0, 0, thickness_mm * 3]) screw_and_washer();
}

assembly();