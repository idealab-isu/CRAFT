// Parameters
thread_nominal_diameter_mm = 2; //[1:4:0.1]
thread_pitch_mm = 0.4; //[0.2:0.8:0.05]
across_flats_mm = 4.9; //[2.45:9.8:0.05]
thickness_mm = 1.6; //[0.8:3.2:0.05]
hole_type = 0; //[0:1:1]
clearance_diameter_mm = 2.2; //[2:3:0.05]
thread_minor_diameter_factor = 0.85; //[0.7:0.95:0.01]
washer_enabled = 1; //[0:1:1]
washer_outer_diameter_mm = 5; //[3:10:0.1]
washer_thickness_mm = 0.5; //[0.25:1.5:0.05]
overlap_mm = 0.8; //[0.2:2:0.1]
eps_mm = 0.05; //[0.01:0.2:0.01]

// Hexagonal Nut
module hex_nut() {
  color("DimGray") {
    difference() {
      linear_extrude(height = thickness_mm, center = true) {
        polygon(points = [
          [across_flats_mm/sqrt(3), 0],
          [across_flats_mm/(2*sqrt(3)), across_flats_mm/2],
          [-across_flats_mm/(2*sqrt(3)), across_flats_mm/2],
          [-across_flats_mm/sqrt(3), 0],
          [-across_flats_mm/(2*sqrt(3)), -across_flats_mm/2],
          [across_flats_mm/(2*sqrt(3)), -across_flats_mm/2]
        ]);
      }
      cylinder(r = ((1-hole_type)*(clearance_diameter_mm/2) + hole_type*(thread_nominal_diameter_mm*thread_minor_diameter_factor/2)), 
               h = thickness_mm + 2*eps_mm, center = true);
    }
  }
}

// Washer
module washer() {
  if (washer_enabled) {
    color("Silver") {
      difference() {
        cylinder(r = washer_outer_diameter_mm/2, h = washer_thickness_mm, center = true);
        cylinder(r = clearance_diameter_mm/2, h = washer_thickness_mm + 2*eps_mm, center = true);
      }
    }
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  union() {
    hex_nut();
    translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - overlap_mm)*washer_enabled]) washer();
  }
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();