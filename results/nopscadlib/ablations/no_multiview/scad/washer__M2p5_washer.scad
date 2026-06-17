// Parameters
inner_diameter_mm = 2.5; //[1.25:5:0.05]
outer_diameter_mm = 5.9; //[2.95:11.8:0.05]
thickness_mm = 0.5; //[0.25:1:0.05]
inner_radius_mm = 1.25; //[0.625:2.5:0.05]
outer_radius_mm = 2.95; //[1.475:5.9:0.05]
hole_clearance_mm = 0.1; //[0:0.3:0.01]
cut_extra_height_mm = 1; //[0.5:3:0.1]

// Washer - base geometry
module washer_body() {
  difference() {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
    cylinder(r=inner_radius_mm + hole_clearance_mm, h=thickness_mm + cut_extra_height_mm, center=true);
  }
}

// Round Grommet Top - detailed geometry
module round_grommet_top() {
  color("Silver") {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
    translate([0, 0, thickness_mm/2])
      cylinder(r=outer_radius_mm/2, h=thickness_mm/2, center=true);
  }
}

// Round Grommet Assembly - detailed geometry
module round_grommet_assembly() {
  color("DimGray") {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
    translate([0, 0, -thickness_mm/2])
      cylinder(r=outer_radius_mm/2, h=thickness_mm/2, center=true);
  }
}

// Nut And Washer - detailed geometry
module nut_and_washer() {
  color("Black") {
    washer_body();
    translate([0, 0, thickness_mm/2])
      cylinder(r=outer_radius_mm/2, h=thickness_mm, center=true);
  }
}

// Screw And Washer - detailed geometry
module screw_and_washer() {
  color("Silver") {
    washer_body();
    translate([0, 0, thickness_mm/2])
      cylinder(r=inner_radius_mm, h=thickness_mm * 2, center=true);
  }
}

// Assembly - combines all parts
module assembly() {
  translate([0, 0, 0]) washer_body();
  translate([0, 0, thickness_mm]) round_grommet_top();
  translate([0, 0, -thickness_mm]) round_grommet_assembly();
  translate([0, 0, thickness_mm * 2]) nut_and_washer();
  translate([0, 0, -thickness_mm * 2]) screw_and_washer();
}

assembly();