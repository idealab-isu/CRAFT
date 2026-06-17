// Parameters
thread_nominal_diameter_mm = 3; //[1.5:6:0.1]
thread_pitch_mm = 0.5; //[0.25:1:0.05]
across_flats_mm = 5.5; //[2.75:11:0.1]
thickness_mm = 1.8; //[0.9:3.6:0.1]
hole_minor_diameter_mm = 2.5; //[1.25:5:0.05]
hole_clearance_diameter_mm = 3.2; //[1.6:6.4:0.05]
chamfer_mm = 0.2; //[0.1:0.6:0.05]
corner_radius_mm = 0; //[0:0.8:0.05]
tolerance_mm = 0.1; //[0:0.3:0.01]
overlap_mm = 0.6; //[0.2:2:0.1]
hex_circumradius_mm = 3.175; //[1.5875:6.35:0.01]
hole_diameter_mm = 2.6; //[1.3:5.2:0.01]
chamfer_radius_mm = 1.8; //[0.9:3.6:0.01]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    difference() {
      // Hex Nut Body
      translate([0, 0, 0])
        cylinder(r=hex_circumradius_mm, h=thickness_mm, center=true, $fn=6);
      
      // Center Threaded Hole
      translate([0, 0, 0])
        cylinder(r=hole_diameter_mm/2, h=thickness_mm + 2*overlap_mm, center=true);
      
      // Lead-in Chamfer Top
      translate([0, 0, thickness_mm/2 - (chamfer_mm + overlap_mm)/2 + overlap_mm/2])
        cylinder(r1=chamfer_radius_mm, r2=0, h=chamfer_mm + overlap_mm, center=true);
      
      // Lead-in Chamfer Bottom
      translate([0, 0, -thickness_mm/2 + (chamfer_mm + overlap_mm)/2 - overlap_mm/2])
        rotate([180, 0, 0])
        cylinder(r1=chamfer_radius_mm, r2=0, h=chamfer_mm + overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();