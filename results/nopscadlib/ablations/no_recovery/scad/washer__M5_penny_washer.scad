// Parameters
inner_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 20; //[10:40:0.1]
thickness_mm = 1.4; //[0.7:2.8:0.1]
eps_mm = 0.8; //[0.2:2:0.1]
jack_outer_diameter_mm = 10; //[6:20:0.1]
jack_length_mm = 12; //[6:30:0.1]
jack_hole_diameter_mm = 4; //[3:6:0.1]
screw_shank_diameter_mm = 4; //[2:8:0.1]
screw_length_mm = 16; //[8:40:0.5]
screw_head_diameter_mm = 8; //[4:16:0.1]
screw_head_height_mm = 3; //[1.5:6:0.1]

// Penny Washer - complete geometry
module penny_washer() {
  color("Silver") {
    difference() {
      cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw Shank
      translate([0, 0, -thickness_mm/2 - screw_length_mm/2 + eps_mm])
        cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
      // Screw Head
      translate([0, 0, -thickness_mm/2 + screw_head_height_mm/2 - eps_mm])
        cylinder(r=screw_head_diameter_mm/2, h=screw_head_height_mm, center=true);
    }
  }
}

// Jack 4mm Plastic - complete geometry
module jack_4mm_plastic() {
  color([0.15, 0.2, 0.35]) {
    difference() {
      translate([0, 0, thickness_mm/2 + jack_length_mm/2 - eps_mm])
        cylinder(r=jack_outer_diameter_mm/2, h=jack_length_mm, center=true);
      translate([0, 0, thickness_mm/2 + jack_length_mm/2 - eps_mm])
        cylinder(r=jack_hole_diameter_mm/2, h=jack_length_mm + 2*eps_mm, center=true);
    }
  }
}

// Jack 4mm - complete geometry
module jack_4mm() {
  jack_4mm_plastic();
}

// Assembly
module assembly() {
  penny_washer();
  screw_and_washer();
  jack_4mm();
}

assembly();