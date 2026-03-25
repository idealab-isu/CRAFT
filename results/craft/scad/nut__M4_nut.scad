// Parameters
thread_diameter_mm = 4.0; //[2.0:8.0:0.1]
across_flats_mm = 8.1; //[4.0:16.2:0.1]
thickness_mm = 3.2; //[1.6:6.4:0.1]
hole_diameter_mm = 3.3; //[2.5:4.5:0.05]
chamfer_mm = 0.3; //[0.0:1.0:0.05]
overlap_mm = 0.6; //[0.2:2.0:0.1]
hex_circumradius_mm = 4.676537180435969; //[2.0:10.0:0.01]
washer_enabled = 1; //[0:1:1]
washer_outer_diameter_mm = 9.0; //[6.0:18.0:0.1]
washer_thickness_mm = 0.8; //[0.4:2.0:0.05]
washer_hole_diameter_mm = 4.3; //[3.6:6.0:0.05]

// M4 Nut - complete geometry
module nut() {
  color("DimGray") {
    difference() {
      // Hex nut body
      cylinder(r=hex_circumradius_mm, h=thickness_mm, center=true, $fn=6);
      // Central thread hole
      translate([0, 0, 0])
        cylinder(r=hole_diameter_mm/2, h=thickness_mm + 2*overlap_mm, center=true);
      // Top and bottom chamfers
      union() {
        translate([0, 0, thickness_mm/2 - (chamfer_mm + overlap_mm)/2 + overlap_mm/2])
          rotate([180, 0, 0])
          cylinder(r1=hex_circumradius_mm + overlap_mm, r2=0, h=chamfer_mm + overlap_mm, center=true);
        translate([0, 0, -thickness_mm/2 + (chamfer_mm + overlap_mm)/2 - overlap_mm/2])
          cylinder(r1=hex_circumradius_mm + overlap_mm, r2=0, h=chamfer_mm + overlap_mm, center=true);
      }
    }
  }
}

// Washer - complete geometry
module washer() {
  if (washer_enabled) {
    color("Silver") {
      difference() {
        // Washer outer
        translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + overlap_mm])
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        // Washer inner hole
        translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + overlap_mm])
          cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  union() {
    nut();
    washer();
  }
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();