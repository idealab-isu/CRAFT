// Parameters
inner_diameter_mm = 2.5; //[1.25:5:0.05]
outer_diameter_mm = 5.9; //[2.95:11.8:0.05]
thickness_mm = 0.5; //[0.25:1:0.05]
inner_radius_mm = 1.25; //[0.625:2.5:0.05]
outer_radius_mm = 2.95; //[1.475:5.9:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Washer with central hole
module washer_disk_with_hole() {
  difference() {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
    cylinder(r=inner_radius_mm, h=thickness_mm + 2*eps_mm, center=true);
  }
}

// Round Grommet Top - Custom geometry
module round_grommet_top() {
  color("Silver") {
    cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
  }
}

// Round Grommet Assembly - Custom geometry
module round_grommet_assembly() {
  color("Silver") {
    union() {
      round_grommet_top();
      washer_disk_with_hole();
    }
  }
}

// Nut and Washer - Custom geometry
module nut_and_washer() {
  color("DimGray") {
    union() {
      // Nut
      translate([0, 0, thickness_mm/2]) cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
      // Washer
      washer_disk_with_hole();
    }
  }
}

// Screw and Washer - Custom geometry
module screw_and_washer() {
  color("Black") {
    union() {
      // Screw head
      translate([0, 0, thickness_mm]) cylinder(r=outer_radius_mm, h=thickness_mm, center=true);
      // Washer
      washer_disk_with_hole();
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, 0]) round_grommet_assembly();
  translate([0, 0, thickness_mm]) nut_and_washer();
  translate([0, 0, 2*thickness_mm]) screw_and_washer();
}

assembly();