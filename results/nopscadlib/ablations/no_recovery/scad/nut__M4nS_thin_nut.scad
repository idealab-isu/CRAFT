// Parameters
thread_nominal_diameter = 4; //[2:8:0.1]
across_flats = 7; //[3.5:14:0.1]
thickness = 2.2; //[1.1:4.4:0.1]
thread_pitch = 0.7; //[0.35:1.4:0.05]
hole_diameter_mode = 0; //[0:1:1]
clearance_hole_diameter = 4.3; //[3.5:6:0.05]
thread_tap_drill_diameter = 3.3; //[2.5:4.2:0.05]
chamfer_size = 0.2; //[0.1:0.6:0.05]
eps = 0.2; //[0.05:0.5:0.05]
washer_outer_diameter = 9; //[4.5:18:0.1]
washer_thickness = 0.8; //[0.4:1.6:0.05]
washer_hole_diameter = 4.5; //[3.5:6.5:0.05]

// Hex Nut with Chamfers
module hex_nut() {
  difference() {
    // Hexagonal nut body
    color("DimGray") {
      cylinder(h=thickness, r=across_flats/(2*cos(30)), center=true, $fn=6);
    }
    // Central hole
    cylinder(h=thickness + 2*eps, r=((1-hole_diameter_mode)*thread_tap_drill_diameter + hole_diameter_mode*clearance_hole_diameter)/2, center=true);
    // Top and bottom chamfers
    for (z = [-thickness/2, thickness/2]) {
      translate([0, 0, z])
        cylinder(h=2*chamfer_size, r=across_flats/(2*cos(30)) + eps, center=true, $fn=6);
    }
  }
}

// Washer
module washer() {
  difference() {
    // Outer washer
    color("Silver") {
      cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
    }
    // Inner hole
    cylinder(h=washer_thickness + 2*eps, r=washer_hole_diameter/2, center=true);
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  union() {
    washer();
    translate([0, 0, washer_thickness/2 + thickness/2 - eps])
      hex_nut();
  }
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();