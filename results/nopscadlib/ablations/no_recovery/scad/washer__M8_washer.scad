// Parameters
inner_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 17; //[8.5:34:0.1]
thickness_mm = 1.6; //[0.8:3.2:0.1]
eps_mm = 0.6; //[0.2:2:0.1]
grommet_flange_extra_d_mm = 6; //[3:12:0.5]
grommet_top_height_mm = 2.4; //[1.2:6:0.1]
grommet_lip_height_mm = 0.8; //[0.4:2:0.1]
screw_shank_d_mm = 6; //[3:12:0.1]
screw_shank_len_mm = 18; //[9:36:0.5]
screw_head_d_mm = 10; //[5:20:0.1]
screw_head_h_mm = 4; //[2:8:0.1]
nut_flat_d_mm = 11; //[5.5:22:0.1]
nut_h_mm = 5; //[2.5:10:0.1]

// Washer - base geometry
module washer_body() {
  color("Silver") difference() {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true);
  }
}

// Round Grommet Top - detailed geometry
module round_grommet_top() {
  color([0.2, 0.2, 0.2]) union() {
    difference() {
      cylinder(r=(outer_diameter_mm + grommet_flange_extra_d_mm)/2, h=grommet_top_height_mm, center=true);
      cylinder(r=inner_diameter_mm/2, h=grommet_top_height_mm + 2*eps_mm, center=true);
    }
    translate([0, 0, -grommet_top_height_mm/2 + grommet_lip_height_mm/2])
      cylinder(r=(inner_diameter_mm/2) + eps_mm, h=grommet_lip_height_mm, center=true);
  }
}

// Round Grommet Assembly - combines washer and grommet top
module round_grommet_assembly() {
  union() {
    washer_body();
    translate([0, 0, thickness_mm/2 + grommet_top_height_mm/2 - eps_mm])
      round_grommet_top();
  }
}

// Screw And Washer - detailed geometry
module screw_and_washer() {
  union() {
    washer_body();
    color("DimGray") {
      translate([0, 0, -(thickness_mm/2 + screw_shank_len_mm/2 - eps_mm)])
        cylinder(r=screw_shank_d_mm/2, h=screw_shank_len_mm, center=true);
      translate([0, 0, thickness_mm/2 + screw_head_h_mm/2 - eps_mm])
        cylinder(r=screw_head_d_mm/2, h=screw_head_h_mm, center=true);
    }
  }
}

// Nut And Washer - detailed geometry
module nut_and_washer() {
  union() {
    washer_body();
    color("DimGray") difference() {
      translate([0, 0, -(thickness_mm/2 + nut_h_mm/2 - eps_mm)])
        cylinder(r=nut_flat_d_mm/2, h=nut_h_mm, center=true);
      translate([0, 0, -(thickness_mm/2 + nut_h_mm/2 - eps_mm)])
        cylinder(r=screw_shank_d_mm/2, h=nut_h_mm + 2*eps_mm, center=true);
    }
  }
}

// Final Assembly
module assembly() {
  translate([0, 0, 0]) round_grommet_assembly();
  translate([0, 0, -thickness_mm - screw_shank_len_mm/2]) screw_and_washer();
  translate([0, 0, -thickness_mm - nut_h_mm/2]) nut_and_washer();
}

assembly();