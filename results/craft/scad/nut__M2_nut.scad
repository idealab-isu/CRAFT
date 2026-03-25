// Parameters
thread_diameter_mm = 2.0; //[1.0:4.0:0.05]
across_flats_mm = 4.9; //[2.45:9.8:0.05]
thickness_mm = 1.6; //[0.8:3.2:0.05]
hole_type = 0; //[0:1:1]
chamfer_top_mm = 0.1; //[0.0:0.4:0.05]
chamfer_bottom_mm = 0.1; //[0.0:0.4:0.05]
clearance_extra_mm = 0.2; //[0.0:0.6:0.05]
thread_pilot_shrink_mm = 0.15; //[0.0:0.4:0.05]
eps_mm = 0.6; //[0.2:2.0:0.1]
washer_enabled = 1; //[0:1:1]
washer_outer_diameter_mm = 5.5; //[3.0:11.0:0.1]
washer_thickness_mm = 0.5; //[0.25:1.5:0.05]
washer_hole_extra_mm = 0.3; //[0.0:0.8:0.05]
washer_overlap_mm = 0.6; //[0.2:1.5:0.1]

// M2 Nut - complete geometry
module nut() {
  color("DimGray") {
    difference() {
      // Hex nut body
      cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, center=true, $fn=6);
      // Central thread hole
      cylinder(r=((thread_diameter_mm + clearance_extra_mm)*(1-hole_type) + (thread_diameter_mm - thread_pilot_shrink_mm)*hole_type)/2, 
               h=thickness_mm + 2*eps_mm, center=true);
      // Top chamfer
      translate([0, 0, thickness_mm/2 - (chamfer_top_mm + eps_mm)/2 + eps_mm/2])
        rotate([180, 0, 0])
        cylinder(r1=across_flats_mm/(2*cos(30)) + eps_mm, r2=0, h=chamfer_top_mm + eps_mm, center=true);
      // Bottom chamfer
      translate([0, 0, -thickness_mm/2 + (chamfer_bottom_mm + eps_mm)/2 - eps_mm/2])
        cylinder(r1=across_flats_mm/(2*cos(30)) + eps_mm, r2=0, h=chamfer_bottom_mm + eps_mm, center=true);
    }
  }
}

// Washer - complete geometry
module washer() {
  if (washer_enabled) {
    color("Silver") {
      difference() {
        // Washer outer
        translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + washer_overlap_mm])
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        // Washer hole
        translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + washer_overlap_mm])
          cylinder(r=(thread_diameter_mm + washer_hole_extra_mm)/2, h=washer_thickness_mm + 2*eps_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  nut();
  washer();
}

assembly();