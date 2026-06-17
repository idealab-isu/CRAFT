// Parameters
inner_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
thickness_mm = 1.5; //[0.75:3:0.05]
clearance_mm = 0.2; //[0:0.6:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Washer - base geometry
module washer() {
  difference() {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    cylinder(r=(inner_diameter_mm + clearance_mm)/2, h=thickness_mm + 2*overlap_mm, center=true);
  }
}

// Round Grommet Top - detailed geometry
module round_grommet_top() {
  color([0.2, 0.2, 0.2]) { // Rubber-like color
    washer();
  }
}

// Round Grommet Assembly - detailed geometry
module round_grommet_assembly() {
  color([0.2, 0.2, 0.2]) { // Rubber-like color
    washer();
  }
}

// Nut And Washer - detailed geometry
module nut_and_washer() {
  color([0.4, 0.4, 0.43]) { // Steel-like color
    union() {
      washer();
      translate([0, 0, thickness_mm/2]) cylinder(r=outer_diameter_mm/2.5, h=thickness_mm, center=true);
    }
  }
}

// Screw And Washer - detailed geometry
module screw_and_washer() {
  color([0.4, 0.4, 0.43]) { // Steel-like color
    union() {
      washer();
      translate([0, 0, thickness_mm/2]) cylinder(r=outer_diameter_mm/3, h=thickness_mm*2, center=true);
    }
  }
}

// Assembly - combines all parts
module assembly() {
  translate([0, 0, 0]) round_grommet_top();
  translate([0, 0, thickness_mm]) round_grommet_assembly();
  translate([0, 0, thickness_mm*2]) nut_and_washer();
  translate([0, 0, thickness_mm*3]) screw_and_washer();
}

// Final assembly call
assembly();