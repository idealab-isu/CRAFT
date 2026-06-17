// Parameters
inner_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
thickness_mm = 1.5; //[0.75:3:0.05]
hole_clearance_mm = 0.2; //[0:0.6:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Washer - base geometry
module washer_solid() {
  color([0.2, 0.2, 0.2]) { // Rubber color
    difference() {
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
      cylinder(r=(inner_diameter_mm + hole_clearance_mm)/2, h=thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Round Grommet Top - detailed geometry
module round_grommet_top() {
  color([0.2, 0.2, 0.2]) {
    translate([0, 0, thickness_mm/2]) {
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    }
  }
}

// Round Grommet Assembly - detailed geometry
module round_grommet_assembly() {
  color([0.2, 0.2, 0.2]) {
    union() {
      washer_solid();
      round_grommet_top();
    }
  }
}

// Nut And Washer - detailed geometry
module nut_and_washer() {
  color([0.4, 0.4, 0.43]) { // Steel color
    union() {
      washer_solid();
      translate([0, 0, thickness_mm]) {
        cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
      }
    }
  }
}

// Screw And Washer - detailed geometry
module screw_and_washer() {
  color([0.4, 0.4, 0.43]) {
    union() {
      washer_solid();
      translate([0, 0, thickness_mm]) {
        cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
      }
    }
  }
}

// Assembly - combines all parts
module assembly() {
  translate([0, 0, 0]) round_grommet_assembly();
  translate([0, 0, thickness_mm * 2]) nut_and_washer();
  translate([0, 0, thickness_mm * 4]) screw_and_washer();
}

assembly();