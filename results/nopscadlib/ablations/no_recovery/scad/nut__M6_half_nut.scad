// Parameters
thread_diameter = 6; //[3:12:0.1]
across_flats = 11.5; //[6:23:0.1]
thickness = 3; //[1.5:6:0.1]
hole_type = 0; //[0:1:1]
clearance_factor = 1.1; //[1.02:1.25:0.01]
tapping_factor = 0.85; //[0.7:0.95:0.01]
hole_diameter = thread_diameter * (tapping_factor + (clearance_factor - tapping_factor) * hole_type); //[4:10:0.1]
eps = 0.6; //[0.2:1.5:0.1]
washer_outer_diameter = 18; //[12:30:0.5]
washer_thickness = 1.2; //[0.6:3:0.1]
washer_hole_diameter = 6.6; //[4:10:0.1]

// Hexagonal Nut Profile
module flat_to_flat_hex_profile() {
  linear_extrude(height=thickness, center=true) {
    polygon(points=[
      [across_flats/(2*sqrt(3)), across_flats/2],
      [across_flats/sqrt(3), 0],
      [across_flats/(2*sqrt(3)), -across_flats/2],
      [-across_flats/(2*sqrt(3)), -across_flats/2],
      [-across_flats/sqrt(3), 0],
      [-across_flats/(2*sqrt(3)), across_flats/2]
    ]);
  }
}

// Central Through Hole
module central_through_hole() {
  cylinder(r=hole_diameter/2, h=thickness + 2*eps, center=true);
}

// Washer Outer
module washer_outer() {
  cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
}

// Washer Hole
module washer_hole() {
  cylinder(r=washer_hole_diameter/2, h=washer_thickness + 2*eps, center=true);
}

// Hex Nut Body
module hex_nut_body() {
  difference() {
    flat_to_flat_hex_profile();
    central_through_hole();
  }
}

// Washer Solid
module washer_solid() {
  difference() {
    washer_outer();
    washer_hole();
  }
}

// Positioned Washer
module washer_positioned() {
  translate([0, 0, -(thickness/2 + washer_thickness/2 - eps)]) {
    washer_solid();
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  union() {
    hex_nut_body();
    washer_positioned();
  }
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();