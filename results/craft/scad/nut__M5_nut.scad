// Parameters
thread_nominal_diameter_mm = 5; //[2.5:10:0.1]
across_flats_mm = 9.2; //[4.6:18.4:0.1]
thickness_mm = 4; //[2:8:0.1]
hole_minor_diameter_mm = 4.2; //[2.1:8.4:0.05]
hole_clearance_diameter_mm = 5.5; //[5:7:0.05]
hole_type = 0; //[0:1:1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
chamfer_mm = 0.3; //[0:1:0.05]
corner_radius_mm = 0; //[0:1:0.05]
eps_mm = 0.6; //[0.2:1.5:0.1]
hex_outer_radius_mm = 5.311; //[2.6555:10.622:0.001]
hole_diameter_mm = 4.2; //[2:7:0.05]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]
washer_hole_diameter_mm = 5.5; //[5:7:0.05]
washer_overlap_mm = 0.8; //[0.3:2:0.1]

// M5 Nut - complete geometry
module nut() {
  color("DimGray") {
    difference() {
      // Hex nut body
      cylinder(r=hex_outer_radius_mm, h=thickness_mm, center=true, $fn=6);
      // Central thread hole
      cylinder(r=hole_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true);
      // Top and bottom chamfers
      union() {
        translate([0, 0, thickness_mm/2 - (chamfer_mm + eps_mm)/2])
          cylinder(r1=hex_outer_radius_mm + eps_mm, r2=0, h=chamfer_mm + eps_mm, center=true);
        translate([0, 0, -thickness_mm/2 + (chamfer_mm + eps_mm)/2])
          rotate([180, 0, 0])
          cylinder(r1=hex_outer_radius_mm + eps_mm, r2=0, h=chamfer_mm + eps_mm, center=true);
      }
    }
  }
}

// Washer - complete geometry
module washer() {
  color("Silver") {
    difference() {
      // Washer outer
      cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
      // Washer hole
      cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  union() {
    nut();
    translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + washer_overlap_mm])
      washer();
  }
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();