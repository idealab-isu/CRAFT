// Parameters
inner_diameter_mm = 3.5; //[1.75:7:0.1]
outer_diameter_mm = 8; //[4:16:0.1]
thickness_mm = 0.5; //[0.25:1:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Washer - base geometry
module washer_ring_body() {
  difference() {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true);
  }
}

// Round Grommet Top - detailed geometry
module round_grommet_top() {
  color("Silver") {
    union() {
      washer_ring_body();
      translate([0, 0, thickness_mm/2]) {
        cylinder(r=outer_diameter_mm/2, h=thickness_mm/2, center=false);
      }
    }
  }
}

// Round Grommet Assembly - detailed geometry
module round_grommet_assembly() {
  color("DimGray") {
    union() {
      round_grommet_top();
      translate([0, 0, thickness_mm]) {
        cylinder(r=outer_diameter_mm/2, h=thickness_mm/2, center=false);
      }
    }
  }
}

// Nut And Washer - detailed geometry
module nut_and_washer() {
  color("Black") {
    union() {
      washer_ring_body();
      translate([0, 0, thickness_mm/2]) {
        cylinder(r=outer_diameter_mm/2, h=thickness_mm/2, center=false);
      }
      translate([0, 0, thickness_mm]) {
        cylinder(r=outer_diameter_mm/2, h=thickness_mm/2, center=false);
      }
    }
  }
}

// Screw And Washer - detailed geometry
module screw_and_washer() {
  color("Silver") {
    union() {
      washer_ring_body();
      translate([0, 0, thickness_mm/2]) {
        cylinder(r=outer_diameter_mm/2, h=thickness_mm/2, center=false);
      }
      translate([0, 0, thickness_mm]) {
        cylinder(r=outer_diameter_mm/2, h=thickness_mm/2, center=false);
      }
      translate([0, 0, thickness_mm + thickness_mm/2]) {
        cylinder(r=inner_diameter_mm/4, h=thickness_mm, center=false);
      }
    }
  }
}

// Assembly - combines all parts
module assembly() {
  translate([0, 0, 0]) round_grommet_top();
  translate([0, 0, thickness_mm]) round_grommet_assembly();
  translate([0, 0, 2*thickness_mm]) nut_and_washer();
  translate([0, 0, 3*thickness_mm]) screw_and_washer();
}

assembly();