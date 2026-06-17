// Parameters
thread_nominal_diameter = 8; //[4:16:0.1]
across_flats = 13; //[6.5:26:0.1]
thickness = 4; //[2:8:0.1]
hole_diameter = 8; //[6:10:0.05]
hex_corner_diameter = 15.011; //[7.5055:30.022:0.001]
chamfer_height = 0.5; //[0.25:1:0.05]
chamfer_angle_deg = 30; //[15:60:1]
washer_outer_diameter = 16; //[8:32:0.1]
washer_thickness = 1.6; //[0.8:3.2:0.1]
overlap = 0.8; //[0.5:2:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hex Nut Body
    difference() {
      cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
      // Central Through Hole and Chamfers
      union() {
        cylinder(r=hole_diameter/2, h=thickness + 2*overlap, center=true);
        // Edge Chamfers
        union() {
          translate([0, 0, thickness/2 - (chamfer_height + overlap)/2])
            cylinder(r1=hole_diameter/2 + chamfer_height*tan(chamfer_angle_deg), 
                     r2=hole_diameter/2, 
                     h=chamfer_height + overlap, 
                     center=true);
          translate([0, 0, -thickness/2 + (chamfer_height + overlap)/2])
            rotate([180, 0, 0])
            cylinder(r1=hole_diameter/2 + chamfer_height*tan(chamfer_angle_deg), 
                     r2=hole_diameter/2, 
                     h=chamfer_height + overlap, 
                     center=true);
        }
      }
    }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, -(thickness/2 + washer_thickness/2 - overlap)])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
      translate([0, 0, -(thickness/2 + washer_thickness/2 - overlap)])
        cylinder(r=hole_diameter/2, h=washer_thickness + 2*overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();