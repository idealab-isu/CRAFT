// Parameters
inner_diameter_mm = 2; //[1:4:0.1]
outer_diameter_mm = 5; //[2.5:10:0.1]
thickness_mm = 0.3; //[0.15:0.6:0.05]
inner_radius_mm = 1; //[0.5:2:0.05]
outer_radius_mm = 2.5; //[1.25:5:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Washer - base geometry
module washer_solid() {
  color("Silver") difference() {
    // Washer body
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    // Center through hole
    cylinder(r=inner_diameter_mm/2, h=thickness_mm + eps_mm, center=true);
  }
}

// Round Grommet Top - detailed geometry
module round_grommet_top() {
  color("DimGray") {
    // Grommet top body
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
  }
}

// Round Grommet Assembly - detailed geometry
module round_grommet_assembly() {
  color("DimGray") {
    // Grommet assembly body
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
  }
}

// Nut And Washer - detailed geometry
module nut_and_washer() {
  color("Black") {
    // Nut body
    translate([0, 0, thickness_mm/2])
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    // Washer
    washer_solid();
  }
}

// Screw And Washer - detailed geometry
module screw_and_washer() {
  color("Black") {
    // Screw body
    translate([0, 0, thickness_mm])
      cylinder(r=inner_diameter_mm/2, h=thickness_mm*2, center=true);
    // Washer
    washer_solid();
  }
}

// Assembly
module assembly() {
  translate([0, 0, 0]) washer_solid();
  translate([0, 0, thickness_mm]) round_grommet_top();
  translate([0, 0, thickness_mm*2]) round_grommet_assembly();
  translate([0, 0, thickness_mm*3]) nut_and_washer();
  translate([0, 0, thickness_mm*4]) screw_and_washer();
}

assembly();