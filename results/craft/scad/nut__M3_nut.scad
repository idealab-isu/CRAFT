// Parameters
thread_nominal_diameter_mm = 3.0; //[1.5:6.0:0.1]
across_flats_mm = 6.4; //[3.2:12.8:0.1]
thickness_mm = 2.4; //[1.2:4.8:0.1]
thread_pitch_mm = 0.5; //[0.25:1.0:0.05]
chamfer_mm = 0.2; //[0.0:0.6:0.05]
hole_clearance_mm = 0.2; //[0.0:0.6:0.05]
hole_extra_height_mm = 0.6; //[0.2:2.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]
washer_outer_diameter_mm = 7.0; //[5.0:14.0:0.1]
washer_thickness_mm = 0.8; //[0.4:2.0:0.1]

// M3 Nut - complete geometry
module nut() {
  color("DimGray") {
    difference() {
      // Hex nut body
      cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, center=true, $fn=6);
      // Central thread hole
      translate([0, 0, 0])
        cylinder(r=(thread_nominal_diameter_mm + hole_clearance_mm)/2, h=thickness_mm + hole_extra_height_mm, center=true);
      // Top chamfer
      translate([0, 0, thickness_mm/2 - chamfer_mm/2 + overlap_mm/2])
        cylinder(r1=across_flats_mm/(2*cos(30)) + overlap_mm, r2=0, h=chamfer_mm, center=true);
      // Bottom chamfer
      translate([0, 0, -(thickness_mm/2 - chamfer_mm/2 + overlap_mm/2)])
        cylinder(r1=across_flats_mm/(2*cos(30)) + overlap_mm, r2=0, h=chamfer_mm, center=true);
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
      translate([0, 0, 0])
        cylinder(r=(thread_nominal_diameter_mm + hole_clearance_mm)/2, h=washer_thickness_mm + hole_extra_height_mm, center=true);
    }
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  union() {
    nut();
    translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - overlap_mm)])
      washer();
  }
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();