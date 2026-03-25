// Parameters
thread_nominal_diameter_mm = 8.0; //[4.0:16.0:0.1]
across_flats_mm = 15.0; //[7.5:30.0:0.1]
thickness_mm = 6.5; //[3.0:13.0:0.1]
hole_diameter_mm = 8.0; //[4.0:16.0:0.1]
threaded = 0; //[0:1:1]
lead_in_chamfer_mm = 0.5; //[0.0:2.0:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
thread_pitch_mm = 1.25; //[0.5:2.5:0.05]
thread_depth_mm = 0.35; //[0.1:0.8:0.05]
washer_enabled = 0; //[0:1:1]
washer_outer_diameter_mm = 16.0; //[8.0:32.0:0.1]
washer_thickness_mm = 1.6; //[0.8:3.2:0.1]
washer_hole_diameter_mm = 8.4; //[4.0:18.0:0.1]
connect_overlap_mm = 0.8; //[0.5:2.0:0.1]

// Hexagonal Nut
module nut() {
  color("DimGray") {
    difference() {
      // Hexagonal body
      cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, center=true, $fn=6);
      // Central through-hole
      translate([0, 0, 0])
        cylinder(r=hole_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true);
      // Top chamfer
      translate([0, 0, thickness_mm/2 - lead_in_chamfer_mm/2 + eps_mm/2])
        rotate([180, 0, 0])
        cylinder(r1=hole_diameter_mm/2 + lead_in_chamfer_mm, r2=0, h=lead_in_chamfer_mm, center=true);
      // Bottom chamfer
      translate([0, 0, -thickness_mm/2 + lead_in_chamfer_mm/2 - eps_mm/2])
        cylinder(r1=hole_diameter_mm/2 + lead_in_chamfer_mm, r2=0, h=lead_in_chamfer_mm, center=true);
      // Optional thread representation
      if (threaded == 1) {
        translate([0, 0, 0])
          cylinder(r=thread_nominal_diameter_mm/2 + thread_depth_mm, h=thickness_mm + 2*eps_mm, center=true);
      }
    }
  }
}

// Nut and Washer
module nut_and_washer() {
  union() {
    nut();
    if (washer_enabled == 1) {
      color("Silver") {
        difference() {
          // Washer outer
          translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - connect_overlap_mm)])
            cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
          // Washer hole
          translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - connect_overlap_mm)])
            cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*eps_mm, center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();