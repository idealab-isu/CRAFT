// Parameters
thread_nominal_diameter_mm = 4; //[2:8:0.1]
across_flats_mm = 8.1; //[4.05:16.2:0.1]
thickness_mm = 3.2; //[1.6:6.4:0.1]
hole_diameter_mm = 4; //[2:6:0.05]
chamfer_mm = 0.3; //[0:1.2:0.05]
corner_radius_mm = 0; //[0:1:0.05]
tolerance_mm = 0; //[-0.2:0.4:0.01]
overlap_mm = 0.8; //[0.2:2:0.1]
washer_outer_diameter_mm = 12; //[6:24:0.1]
washer_thickness_mm = 1; //[0.5:2:0.05]

// Hex Nut with Washer
module nut_and_washer() {
  color("DimGray") {
    // Hex Nut Body
    difference() {
      cylinder(h=thickness_mm, r=(across_flats_mm + tolerance_mm) / (2 * cos(30)), center=true, $fn=6);
      // Central Through Hole
      cylinder(h=thickness_mm + 2*overlap_mm, r=(hole_diameter_mm + tolerance_mm) / 2, center=true);
    }
    // Top and Bottom Chamfers
    difference() {
      union() {
        translate([0, 0, thickness_mm/2 - (chamfer_mm + overlap_mm)/2])
          cylinder(h=chamfer_mm + overlap_mm, r1=(across_flats_mm + tolerance_mm) / (2 * cos(30)) + chamfer_mm, r2=0, center=true, $fn=6);
        translate([0, 0, -thickness_mm/2 + (chamfer_mm + overlap_mm)/2])
          cylinder(h=chamfer_mm + overlap_mm, r1=(across_flats_mm + tolerance_mm) / (2 * cos(30)) + chamfer_mm, r2=0, center=true, $fn=6);
      }
    }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
      translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + overlap_mm])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=(hole_diameter_mm + tolerance_mm) / 2, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();