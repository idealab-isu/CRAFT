// Parameters
thread_nominal_diameter = 5; //[2.5:10:0.1]
across_flats = 9.2; //[4.6:18.4:0.1]
thickness = 4; //[2:8:0.1]
hole_diameter = 5; //[2.5:10:0.1]
eps = 0.6; //[0.2:2:0.1]
washer_outer_diameter = 10; //[5:20:0.1]
washer_thickness = 1; //[0.5:2:0.1]

// Hexagonal Nut
module hex_nut() {
  color("DimGray") {
    difference() {
      intersection() {
        // Hexagonal profile
        linear_extrude(height=thickness, center=true) {
          polygon(points=[
            [across_flats/2, 0],
            [across_flats/4, across_flats*sqrt(3)/4],
            [-across_flats/4, across_flats*sqrt(3)/4],
            [-across_flats/2, 0],
            [-across_flats/4, -across_flats*sqrt(3)/4],
            [across_flats/4, -across_flats*sqrt(3)/4]
          ]);
        }
        // Circular body
        cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
      }
      // Central through-hole
      cylinder(r=hole_diameter/2, h=thickness + 2*eps, center=true);
    }
  }
}

// Washer
module washer() {
  color("Silver") {
    difference() {
      // Outer washer
      cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true, $fn=64);
      // Washer hole
      cylinder(r=hole_diameter/2, h=washer_thickness + 2*eps, center=true);
    }
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  hex_nut();
  translate([0, 0, -(thickness/2 + washer_thickness/2 - eps)]) washer();
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();