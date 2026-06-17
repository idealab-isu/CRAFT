// Parameters
inner_hole_diameter_mm = 6; //[3:12:0.1]
outer_diameter_mm = 12.5; //[6.25:25:0.1]
thickness_mm = 1.5; //[0.75:3:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]
hole_clearance_mm = 0.2; //[0:0.6:0.05]
grommet_lip_radial_mm = 1.2; //[0.6:2.4:0.1]
grommet_lip_height_mm = 0.8; //[0.4:1.6:0.05]
grommet_inner_relief_mm = 0.6; //[0.2:1.5:0.05]
nut_outer_diameter_mm = 18; //[9:36:0.1]
nut_thickness_mm = 5; //[2.5:10:0.1]
screw_shank_diameter_mm = 6; //[3:12:0.1]
screw_length_mm = 25; //[12.5:50:0.5]
screw_head_diameter_mm = 12; //[6:24:0.1]
screw_head_height_mm = 4; //[2:8:0.1]

// Washer with through-hole
module washer_body() {
  color("Silver") difference() {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    translate([0, 0, 0])
      cylinder(r=(inner_hole_diameter_mm + hole_clearance_mm)/2, h=thickness_mm + 2*overlap_mm, center=true);
  }
}

// Round Grommet Top
module round_grommet_top() {
  color([0.2, 0.2, 0.2]) difference() {
    translate([0, 0, thickness_mm/2 + grommet_lip_height_mm/2 - overlap_mm])
      cylinder(r=outer_diameter_mm/2 + grommet_lip_radial_mm, h=grommet_lip_height_mm, center=true);
    translate([0, 0, thickness_mm/2 + grommet_lip_height_mm/2 - overlap_mm])
      cylinder(r=(inner_hole_diameter_mm + hole_clearance_mm)/2 + grommet_inner_relief_mm, h=grommet_lip_height_mm + 2*overlap_mm, center=true);
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
  color("DimGray") union() {
    washer_body();
    translate([0, 0, -(thickness_mm/2 + nut_thickness_mm/2 - overlap_mm)])
      difference() {
        cylinder(r=nut_outer_diameter_mm/2, h=nut_thickness_mm, center=true);
        cylinder(r=(inner_hole_diameter_mm + hole_clearance_mm)/2, h=nut_thickness_mm + 2*overlap_mm, center=true);
      }
  }
}

// Screw and Washer
module screw_and_washer() {
  color("Black") union() {
    washer_body();
    translate([0, 0, screw_length_mm/2 - (thickness_mm/2 + nut_thickness_mm - overlap_mm)])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
    translate([0, 0, thickness_mm/2 + grommet_lip_height_mm + screw_head_height_mm/2 - overlap_mm])
      cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
  }
}

// Final Assembly
module assembly() {
  round_grommet_assembly();
  translate([0, 0, -thickness_mm/2])
    nut_and_washer();
  translate([0, 0, thickness_mm/2])
    screw_and_washer();
}

assembly();