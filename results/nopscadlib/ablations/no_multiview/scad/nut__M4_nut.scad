// Parameters
thread_diameter = 4.0; //[2.0:8.0:0.1]
across_flats = 8.1; //[4.0:16.2:0.1]
thickness = 3.2; //[1.6:6.4:0.1]
chamfer_enabled = 1; //[0:1:1]
chamfer_size = 0.4; //[0.2:1.0:0.05]
hole_clearance = 0.2; //[0.0:0.6:0.05]
overlap = 0.8; //[0.5:2.0:0.1]

// Hex Nut - complete geometry
module hex_nut() {
  color("DimGray") {
    difference() {
      // Hexagonal body
      cylinder(h=thickness, r=(across_flats/2)/cos(30), $fn=6, center=true);
      // Central through-hole
      translate([0, 0, 0])
        cylinder(h=thickness + 2*overlap, r=(thread_diameter + hole_clearance)/2, center=true);
      
      // Chamfers
      if (chamfer_enabled) {
        translate([0, 0, thickness/2 - chamfer_size/2 + overlap/2])
          rotate([180, 0, 0])
          cylinder(h=chamfer_size, r1=(thread_diameter + hole_clearance)/2 + chamfer_size, r2=0, center=true);
        
        translate([0, 0, -thickness/2 + chamfer_size/2 - overlap/2])
          cylinder(h=chamfer_size, r1=(thread_diameter + hole_clearance)/2 + chamfer_size, r2=0, center=true);
      }
    }
  }
}

// Nut and Washer - complete geometry
module nut_and_washer() {
  hex_nut();
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();