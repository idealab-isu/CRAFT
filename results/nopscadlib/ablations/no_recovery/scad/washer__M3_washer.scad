// Parameters
inner_diameter_mm = 3.0; //[1.5:6.0:0.1]
outer_diameter_mm = 7.0; //[3.5:14.0:0.1]
thickness_mm = 0.5; //[0.25:1.0:0.05]
inner_radius_mm = 1.5; //[0.75:3.0:0.05]
outer_radius_mm = 3.5; //[1.75:7.0:0.05]
overlap_mm = 0.8; //[0.5:2.0:0.1]
grommet_top_extra_radius_mm = 1.0; //[0.5:3.0:0.1]
grommet_top_height_mm = 1.0; //[0.5:4.0:0.1]
nut_flat_width_mm = 6.0; //[3.0:12.0:0.1]
nut_thickness_mm = 2.4; //[1.2:5.0:0.1]
screw_shank_diameter_mm = 3.0; //[1.5:6.0:0.1]
screw_shank_length_mm = 10.0; //[5.0:30.0:0.5]
screw_head_diameter_mm = 6.0; //[3.0:12.0:0.1]
screw_head_height_mm = 2.0; //[1.0:5.0:0.1]

// Washer - base geometry
module washer_body() {
  color("Silver") difference() {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    translate([0, 0, 0])
      cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*overlap_mm, center=true);
  }
}

// Round Grommet Top
module round_grommet_top() {
  color("DimGray") difference() {
    translate([0, 0, thickness_mm/2 + grommet_top_height_mm/2 - overlap_mm])
      cylinder(r=outer_diameter_mm/2 + grommet_top_extra_radius_mm, h=grommet_top_height_mm, center=true);
    translate([0, 0, thickness_mm/2 + grommet_top_height_mm/2 - overlap_mm])
      cylinder(r=inner_diameter_mm/2, h=grommet_top_height_mm + 2*overlap_mm, center=true);
  }
}

// Round Grommet Assembly
module round_grommet_assembly() {
  union() {
    washer_body();
    round_grommet_top();
  }
}

// Nut and Washer
module nut_and_washer() {
  color("Black") union() {
    washer_body();
    translate([0, 0, thickness_mm/2 + nut_thickness_mm/2 - overlap_mm])
      difference() {
        cylinder(r=nut_flat_width_mm/2, h=nut_thickness_mm, center=true);
        translate([0, 0, thickness_mm/2 + nut_thickness_mm/2 - overlap_mm])
          cylinder(r=inner_diameter_mm/2, h=nut_thickness_mm + 2*overlap_mm, center=true);
      }
  }
}

// Screw and Washer
module screw_and_washer() {
  color("SteelBlue") union() {
    washer_body();
    translate([0, 0, thickness_mm/2 + screw_shank_length_mm/2 - overlap_mm])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_shank_length_mm, center=true);
    translate([0, 0, -thickness_mm/2 - screw_head_height_mm/2 + overlap_mm])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
  }
}

// Final Assembly
module assembly() {
  round_grommet_assembly();
  translate([0, 0, 5]) nut_and_washer();
  translate([0, 0, 10]) screw_and_washer();
}

assembly();