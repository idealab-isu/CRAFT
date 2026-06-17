// Parameters
inner_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
thickness_mm = 1; //[0.5:2:0.1]
inner_radius_mm = 2.5; //[1.25:5:0.1]
outer_radius_mm = 5; //[2.5:10:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]
grommet_lip_height_mm = 0.6; //[0.3:1.2:0.1]
grommet_lip_radial_mm = 0.6; //[0.3:1.5:0.1]
screw_shank_radius_mm = 1.2; //[0.6:2.4:0.1]
screw_shank_length_mm = 8; //[4:16:0.5]
nut_radius_mm = 3.2; //[1.6:6.4:0.1]
nut_thickness_mm = 2.5; //[1.25:5:0.1]

// Round Grommet Top
module round_grommet_top() {
  color([0.85, 0.85, 0.8]) {
    translate([0, 0, thickness_mm/2 + grommet_lip_height_mm/2 - overlap_mm])
      cylinder(r=outer_radius_mm + grommet_lip_radial_mm, h=grommet_lip_height_mm, center=true);
  }
}

// Round Grommet Assembly
module round_grommet_assembly() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
      cylinder(r=inner_radius_mm, h=thickness_mm + 2*overlap_mm, center=true);
    }
    round_grommet_top();
  }
}

// Nut And Washer
module nut_and_washer() {
  color([0.8, 0.6, 0.2]) {
    translate([0, 0, -thickness_mm/2 - nut_thickness_mm/2 + overlap_mm])
      cylinder(r=nut_radius_mm, h=nut_thickness_mm, center=true);
  }
}

// Screw And Washer
module screw_and_washer() {
  color([0.4, 0.4, 0.43]) {
    translate([0, 0, thickness_mm/2 + screw_shank_length_mm/2 - overlap_mm])
      cylinder(r=screw_shank_radius_mm, h=screw_shank_length_mm, center=true);
  }
}

// Assembly
module assembly() {
  union() {
    round_grommet_assembly();
    screw_and_washer();
    nut_and_washer();
  }
}

assembly();