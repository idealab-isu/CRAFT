// Parameters
inner_diameter_mm = 2.0; //[1.0:4.0:0.1]
outer_diameter_mm = 5.0; //[2.5:10.0:0.1]
thickness_mm = 0.3; //[0.15:0.6:0.05]
inner_radius_mm = 1.0; //[0.5:2.0:0.05]
outer_radius_mm = 2.5; //[1.25:5.0:0.05]
overlap_mm = 0.6; //[0.2:2.0:0.1]
hole_height_factor = 3.0; //[2.0:10.0:0.5]

// Washer Body
module washer_body() {
  difference() {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
    cylinder(r=inner_radius_mm, h=thickness_mm*hole_height_factor, center=true);
  }
}

// Round Grommet Top
module round_grommet_top() {
  color("Silver") {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
  }
}

// Round Grommet Assembly
module round_grommet_assembly() {
  union() {
    washer_body();
    translate([0, 0, thickness_mm]) round_grommet_top();
  }
}

// Nut and Washer
module nut_and_washer() {
  union() {
    washer_body();
    translate([0, 0, thickness_mm/2 + thickness_mm - overlap_mm]) 
      cylinder(r=outer_radius_mm*0.6, h=thickness_mm*2, center=true);
  }
}

// Screw and Washer
module screw_and_washer() {
  union() {
    washer_body();
    translate([0, 0, 0]) 
      cylinder(r=inner_radius_mm*0.8, h=thickness_mm*6, center=true);
  }
}

// Assembly
module assembly() {
  translate([0, 0, 0]) round_grommet_assembly();
  translate([0, 0, thickness_mm*3]) nut_and_washer();
  translate([0, 0, thickness_mm*6]) screw_and_washer();
}

assembly();