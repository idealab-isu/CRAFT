// Parameters
inner_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 14.0; //[7.0:28.0:0.1]
thickness_mm = 0.8; //[0.4:1.6:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]
grommet_lip_thickness_mm = 0.4; //[0.2:1.0:0.05]
grommet_lip_radial_mm = 0.8; //[0.4:2.0:0.1]
screw_shank_diameter_mm = 3.5; //[2.0:6.0:0.1]
screw_length_mm = 12.0; //[6.0:30.0:1]
screw_head_diameter_mm = 6.5; //[4.0:12.0:0.1]
screw_head_height_mm = 2.5; //[1.5:6.0:0.1]
connect_overlap_mm = 0.6; //[0.2:2.0:0.1]

// Penny Washer - complete geometry
module penny_washer() {
  color("Silver") {
    difference() {
      // Washer body
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
      // Center through-hole
      translate([0, 0, 0])
        cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Round Grommet Top - complete geometry
module round_grommet_top() {
  color("DimGray") {
    difference() {
      // Grommet top outer
      translate([0, 0, thickness_mm/2 + grommet_lip_thickness_mm/2 - connect_overlap_mm])
        cylinder(r=outer_diameter_mm/2 + grommet_lip_radial_mm, h=grommet_lip_thickness_mm, center=true);
      // Grommet top inner hole
      translate([0, 0, thickness_mm/2 + grommet_lip_thickness_mm/2 - connect_overlap_mm])
        cylinder(r=inner_diameter_mm/2, h=grommet_lip_thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Screw And Washer - complete geometry
module screw_and_washer() {
  color("Black") {
    union() {
      // Screw shank
      translate([0, 0, -(thickness_mm/2 + screw_length_mm/2 - connect_overlap_mm)])
        cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
      // Screw head
      translate([0, 0, thickness_mm/2 + screw_head_height_mm/2 - connect_overlap_mm])
        cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
    }
  }
}

// Round Grommet Assembly - complete geometry
module round_grommet_assembly() {
  union() {
    penny_washer();
    round_grommet_top();
  }
}

// Assembly - combines all parts
module assembly() {
  round_grommet_assembly();
  screw_and_washer();
}

assembly();