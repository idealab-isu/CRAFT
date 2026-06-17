// Parameters
inner_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 9.0; //[4.5:18.0:0.1]
thickness_mm = 0.8; //[0.4:1.6:0.05]
inner_radius_mm = 2.0; //[1.0:4.0:0.05]
outer_radius_mm = 4.5; //[2.25:9.0:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
hole_cut_height_mm = 3.0; //[1.6:10.0:0.1]
grommet_wall_mm = 1.2; //[0.6:2.4:0.1]
grommet_top_height_mm = 2.0; //[1.0:6.0:0.1]
grommet_outer_radius_mm = 6.0; //[4.8:12.0:0.1]
nut_flat_width_mm = 8.0; //[4.0:16.0:0.1]
nut_thickness_mm = 3.2; //[1.6:6.4:0.1]
screw_shank_radius_mm = 2.0; //[1.0:4.0:0.05]
screw_shank_length_mm = 12.0; //[6.0:24.0:0.5]
screw_head_radius_mm = 4.0; //[2.0:8.0:0.1]
screw_head_height_mm = 2.5; //[1.2:5.0:0.1]

// Washer - base geometry
module washer_solid() {
  color("Silver") difference() {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
    cylinder(r=inner_radius_mm, h=hole_cut_height_mm, center=true);
  }
}

// Round Grommet Top - detailed geometry
module round_grommet_top() {
  color("DimGray") difference() {
    translate([0, 0, thickness_mm/2 + grommet_top_height_mm/2 - overlap_mm])
      cylinder(r=grommet_outer_radius_mm, h=grommet_top_height_mm, center=true);
    translate([0, 0, thickness_mm/2 + grommet_top_height_mm/2 - overlap_mm])
      cylinder(r=grommet_outer_radius_mm - grommet_wall_mm, h=grommet_top_height_mm + 2*overlap_mm, center=true);
  }
}

// Round Grommet Assembly - combines washer and grommet
module round_grommet_assembly() {
  union() {
    washer_solid();
    round_grommet_top();
  }
}

// Nut and Washer - detailed geometry
module nut_and_washer() {
  color("Black") union() {
    washer_solid();
    translate([0, 0, -thickness_mm/2 - nut_thickness_mm/2 + overlap_mm])
      cube([nut_flat_width_mm, nut_flat_width_mm, nut_thickness_mm], center=true);
  }
}

// Screw and Washer - detailed geometry
module screw_and_washer() {
  color("SteelBlue") union() {
    washer_solid();
    translate([0, 0, screw_shank_length_mm/2 - thickness_mm/2 + overlap_mm])
      cylinder(r=screw_shank_radius_mm, h=screw_shank_length_mm, center=true);
    translate([0, 0, thickness_mm/2 + screw_head_height_mm/2 - overlap_mm])
      cylinder(r=screw_head_radius_mm, h=screw_head_height_mm, center=true);
  }
}

// Final Assembly
module assembly() {
  round_grommet_assembly();
  translate([0, 0, -10]) nut_and_washer();
  translate([0, 0, 10]) screw_and_washer();
}

assembly();