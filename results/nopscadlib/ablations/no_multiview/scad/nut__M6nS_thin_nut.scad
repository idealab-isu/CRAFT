// Parameters
thread_diameter = 6; //[3:12:0.1]
across_flats = 10; //[5:20:0.1]
thickness = 3.2; //[1.6:6.4:0.1]
hole_diameter = 6.6; //[5.5:7.5:0.05]
edge_break_size = 0.2; //[0.1:0.6:0.05]
overlap = 0.6; //[0.2:2:0.1]
washer_outer_diameter = 12; //[8:24:0.1]
washer_thickness = 1.2; //[0.6:2.4:0.1]

// Hexagonal Nut with Chamfer
module hex_nut() {
  difference() {
    // Hex Nut Body
    cylinder(h=thickness, r=across_flats/(2*cos(30)), center=true, $fn=6);
    // Thread Hole
    translate([0, 0, 0])
      cylinder(h=thickness + 2*overlap, r=hole_diameter/2, center=true);
    // Chamfer Top
    translate([0, 0, thickness/2 - edge_break_size])
      cylinder(h=2*edge_break_size, r1=across_flats/(2*cos(30)) + edge_break_size, r2=across_flats/(2*cos(30)) - edge_break_size, center=true);
    // Chamfer Bottom
    translate([0, 0, -thickness/2 + edge_break_size])
      cylinder(h=2*edge_break_size, r1=across_flats/(2*cos(30)) - edge_break_size, r2=across_flats/(2*cos(30)) + edge_break_size, center=true);
  }
}

// Washer
module washer() {
  difference() {
    // Washer Outer
    translate([0, 0, -(thickness/2 + washer_thickness/2 - overlap)])
      cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
    // Washer Hole
    translate([0, 0, -(thickness/2 + washer_thickness/2 - overlap)])
      cylinder(h=washer_thickness + 2*overlap, r=hole_diameter/2, center=true);
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