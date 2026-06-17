// Parameters
thread_diameter = 6; //[3:12:0.1]
across_flats = 11.5; //[6:23:0.1]
thickness = 5; //[2.5:10:0.1]
hole_clearance = 0; //[0:1:0.05]
overlap = 1; //[0.5:2:0.1]
washer_enabled = 0; //[0:1:1]
washer_outer_diameter = 18; //[9:36:0.1]
washer_thickness = 1.6; //[0.8:3.2:0.1]

// Hexagonal Nut
module hex_nut() {
  color("DimGray") {
    difference() {
      // Hex nut body
      cylinder(h=thickness, r=across_flats/(2*cos(30)), center=true, $fn=6);
      // Central through-hole
      translate([0, 0, 0])
        cylinder(h=thickness + 2*overlap, r=(thread_diameter + hole_clearance)/2, center=true);
    }
  }
}

// Washer
module washer() {
  if (washer_enabled) {
    color("Silver") {
      difference() {
        // Washer outer
        translate([0, 0, -(thickness/2 + washer_thickness/2 - overlap)])
          cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
        // Washer hole
        translate([0, 0, -(thickness/2 + washer_thickness/2 - overlap)])
          cylinder(h=washer_thickness + 2*overlap, r=(thread_diameter + hole_clearance)/2, center=true);
      }
    }
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  union() {
    hex_nut();
    washer();
  }
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();