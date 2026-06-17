// Parameters
thread_nominal_diameter = 4; //[2:8:0.1]
across_flats = 5.3; //[3:10.6:0.1]
thickness = 6.3; //[3.15:12.6:0.1]
bore_clearance_diameter = 4.3; //[4.1:4.8:0.05]
bore_pilot_diameter = 3.3; //[3:3.6:0.05]
bore_type_selector = 0; //[0:1:1]
chamfer_size = 0.4; //[0.2:1:0.05]
overlap = 0.8; //[0.5:2:0.1]
washer_outer_diameter = 9; //[6:18:0.1]
washer_thickness = 1; //[0.5:3:0.1]

// Hex Nut - complete geometry
module hex_nut() {
  color("DimGray") {
    difference() {
      // Hexagonal body
      cylinder(h=thickness, r=across_flats/(2*cos(30)), center=true, $fn=6);
      
      // Central bore
      cylinder(h=thickness + 2*overlap, 
               r=((1-bore_type_selector)*bore_clearance_diameter + bore_type_selector*bore_pilot_diameter)/2, 
               center=true);
      
      // Top chamfer
      translate([0, 0, thickness/2 - chamfer_size/2 + overlap/2])
        cylinder(h=chamfer_size, r1=across_flats/(2*cos(30)) + overlap, r2=0, center=true);
      
      // Bottom chamfer
      translate([0, 0, -thickness/2 + chamfer_size/2 - overlap/2])
        cylinder(h=chamfer_size, r1=across_flats/(2*cos(30)) + overlap, r2=0, center=true);
    }
  }
}

// Washer - complete geometry
module washer() {
  color("Silver") {
    difference() {
      // Outer washer
      cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
      
      // Washer bore
      cylinder(h=washer_thickness + 2*overlap, r=bore_clearance_diameter/2, center=true);
    }
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  hex_nut();
  translate([0, 0, -(thickness/2 + washer_thickness/2 - overlap)]) washer();
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();