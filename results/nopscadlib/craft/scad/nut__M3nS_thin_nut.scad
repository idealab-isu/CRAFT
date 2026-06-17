// Parameters
thread_nominal_diameter_mm = 3; //[1.5:6:0.1]
across_flats_mm = 5.5; //[2.75:11:0.1]
thickness_mm = 1.8; //[0.9:3.6:0.1]
hole_diameter_mm = 3; //[2.4:3.6:0.05]
outer_profile_sides = 6; //[6:6:1]
chamfer_mm = 0.2; //[0.1:0.6:0.05]
overlap_mm = 0.6; //[0.2:1.5:0.1]
washer_outer_diameter_mm = 7; //[5:14:0.1]
washer_thickness_mm = 0.8; //[0.4:1.6:0.1]
washer_hole_diameter_mm = 3.2; //[2.8:4:0.05]

// Hex Nut - complete geometry
module hex_nut() {
  color("DimGray") {
    difference() {
      // Hexagonal body
      cylinder(h=thickness_mm, r=across_flats_mm/(2*cos(30)), $fn=outer_profile_sides, center=true);
      // Central through-hole with chamfers
      union() {
        // Central hole
        cylinder(h=thickness_mm + 2*overlap_mm, r=hole_diameter_mm/2, center=true);
        // Top chamfer
        translate([0, 0, thickness_mm/2 - chamfer_mm/2 + overlap_mm/2])
          rotate([180, 0, 0])
          cylinder(h=chamfer_mm, r1=hole_diameter_mm/2 + chamfer_mm, r2=hole_diameter_mm/2, center=true);
        // Bottom chamfer
        translate([0, 0, -thickness_mm/2 + chamfer_mm/2 - overlap_mm/2])
          cylinder(h=chamfer_mm, r1=hole_diameter_mm/2 + chamfer_mm, r2=hole_diameter_mm/2, center=true);
      }
    }
  }
}

// Washer - complete geometry
module washer() {
  color("Silver") {
    difference() {
      // Outer washer
      cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      // Inner hole
      cylinder(h=washer_thickness_mm + 2*overlap_mm, r=washer_hole_diameter_mm/2, center=true);
    }
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  hex_nut();
  translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - overlap_mm)]) washer();
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();