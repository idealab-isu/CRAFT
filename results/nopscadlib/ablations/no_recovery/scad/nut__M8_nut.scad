// Parameters
thread_nominal_diameter = 8.0; //[4.0:16.0:0.1]
across_flats = 15.0; //[7.5:30.0:0.1]
thickness = 6.5; //[3.25:13.0:0.1]
hole_diameter = 8.0; //[4.0:16.0:0.1]
threaded_hole = 1; //[0:1:1]
chamfer_size = 0.5; //[0.25:1.0:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
washer_outer_diameter = 22.0; //[11.0:44.0:0.1]
washer_thickness = 1.6; //[0.8:3.2:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hexagonal prism body
    difference() {
      union() {
        // Hexagonal nut body
        translate([0, 0, 0])
          cylinder(h=thickness, r=across_flats/(2*cos(30)), $fn=6, center=true);
        
        // Washer outer cylinder
        translate([0, 0, -thickness/2 - washer_thickness/2 + overlap])
          cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
      }
      
      // Central through hole
      translate([0, 0, 0])
        cylinder(h=thickness + 2*overlap, r=hole_diameter/2, center=true);
      
      // Washer inner hole
      translate([0, 0, -thickness/2 - washer_thickness/2 + overlap])
        cylinder(h=washer_thickness + 2*overlap, r=hole_diameter/2, center=true);
      
      // Edge chamfers or lead-in
      union() {
        // Top chamfer
        translate([0, 0, thickness/2 - chamfer_size/2 + overlap/2])
          cylinder(h=chamfer_size, r1=hole_diameter/2 + chamfer_size, r2=hole_diameter/2, center=true);
        
        // Bottom chamfer
        translate([0, 0, -thickness/2 + chamfer_size/2 - overlap/2])
          cylinder(h=chamfer_size, r1=hole_diameter/2 + chamfer_size, r2=hole_diameter/2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();