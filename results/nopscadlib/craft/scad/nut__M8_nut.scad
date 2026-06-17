// Parameters
thread_nominal_diameter_mm = 8.0; //[4.0:16.0:0.1]
across_flats_mm = 15.0; //[7.5:30.0:0.1]
thickness_mm = 6.5; //[3.25:13.0:0.1]
hole_diameter_mm = 8.0; //[4.0:16.0:0.05]
chamfer_height_mm = 0.8; //[0.4:1.6:0.05]
chamfer_radial_mm = 0.6; //[0.3:1.2:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]
outer_profile = 6; //[6:6:1]

// Hex Nut - complete geometry
module nut_and_washer() {
  color("DimGray") {
    difference() {
      // Hex Nut Body
      cylinder(h=thickness_mm, r=across_flats_mm/(2*cos(30)), $fn=outer_profile, center=true);
      
      // Central Through Hole
      cylinder(h=thickness_mm + 2*eps_mm, r=hole_diameter_mm/2, center=true);
      
      // Edge Chamfers or Lead-in
      union() {
        // Top Cone
        translate([0, 0, thickness_mm/2 - (chamfer_height_mm + eps_mm)/2 + eps_mm/2])
          rotate([180, 0, 0])
          cylinder(h=chamfer_height_mm + eps_mm, r1=hole_diameter_mm/2 + chamfer_radial_mm, r2=hole_diameter_mm/2, center=true);
        
        // Bottom Cone
        translate([0, 0, -thickness_mm/2 + (chamfer_height_mm + eps_mm)/2 - eps_mm/2])
          cylinder(h=chamfer_height_mm + eps_mm, r1=hole_diameter_mm/2 + chamfer_radial_mm, r2=hole_diameter_mm/2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();