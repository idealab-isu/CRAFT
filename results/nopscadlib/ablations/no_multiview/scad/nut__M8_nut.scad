// Parameters
thread_diameter = 8.0; //[4.0:16.0:0.1]
across_flats = 15.0; //[7.5:30.0:0.1]
thickness = 6.5; //[3.25:13.0:0.1]
hole_clearance = 0.0; //[0.0:1.0:0.05]
overlap = 0.8; //[0.5:2.0:0.1]

// Hexagonal Nut - complete geometry
module hex_nut() {
  color("DimGray") {
    // Hexagonal body
    linear_extrude(height = thickness, center = true) {
      polygon(points = [
        [across_flats/sqrt(3), 0],
        [across_flats/(2*sqrt(3)), across_flats/2],
        [-across_flats/(2*sqrt(3)), across_flats/2],
        [-across_flats/sqrt(3), 0],
        [-across_flats/(2*sqrt(3)), -across_flats/2],
        [across_flats/(2*sqrt(3)), -across_flats/2]
      ]);
    }
  }
}

// Through-hole for the nut
module through_hole() {
  color("Silver") {
    cylinder(r = (thread_diameter + hole_clearance) / 2, h = thickness + 2 * overlap, center = true);
  }
}

// Nut and Washer - complete assembly
module nut_and_washer() {
  difference() {
    hex_nut();
    through_hole();
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();