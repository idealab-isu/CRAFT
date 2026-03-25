// Parameters
thread_nominal_diameter_mm = 6.0; //[3.0:12.0:0.1]
across_flats_mm = 11.5; //[6.0:23.0:0.1]
thickness_mm = 3.0; //[1.5:6.0:0.1]
hole_diameter_mm = 6.0; //[5.0:7.5:0.05]
profile_sides = 6; //[6:6:1]
chamfer_top_mm = 0.0; //[0.0:1.5:0.1]
chamfer_bottom_mm = 0.0; //[0.0:1.5:0.1]
eps_mm = 0.6; //[0.2:2.0:0.1]
washer_outer_diameter_mm = 12.0; //[8.0:24.0:0.1]
washer_thickness_mm = 1.0; //[0.5:3.0:0.1]
washer_hole_diameter_mm = 6.4; //[6.0:8.0:0.05]

// M6 Half Nut - complete geometry
module nut() {
  color("DimGray") {
    difference() {
      // Hex nut body
      cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, center=true, $fn=profile_sides);
      // Central through hole
      cylinder(r=hole_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Nut and Washer - complete geometry
module nut_and_washer() {
  union() {
    nut();
    translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - eps_mm)]) {
      color("Silver") {
        difference() {
          // Washer outer
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
          // Washer hole
          cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*eps_mm, center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();