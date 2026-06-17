// Parameters
thread_nominal_diameter = 6; //[3:12:0.1]
across_flats = 11.5; //[6:23:0.1]
thickness = 5; //[2.5:10:0.1]
hole_diameter = 6; //[3:12:0.1]
include_threads = 0; //[0:1:1]
edge_chamfer = 0.2; //[0:1:0.05]
tolerance_clearance = 0; //[0:0.5:0.05]
overlap = 0.8; //[0.5:2:0.1]
washer_outer_diameter = 18; //[12:36:0.1]
washer_thickness = 1.6; //[0.8:3.2:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Nut with chamfer
    difference() {
      // Hex prism body
      cylinder(h=thickness, r=across_flats/(2*cos(30)), center=true, $fn=6);
      // Chamfer top cone
      translate([0, 0, thickness/2 - edge_chamfer/2])
        cylinder(h=edge_chamfer, r1=across_flats/(2*cos(30)), r2=0, center=true, $fn=6);
      // Chamfer bottom cone
      translate([0, 0, -thickness/2 + edge_chamfer/2])
        rotate([180, 0, 0])
        cylinder(h=edge_chamfer, r1=across_flats/(2*cos(30)), r2=0, center=true, $fn=6);
      // Central through hole
      cylinder(h=thickness + 2*overlap, r=(hole_diameter + tolerance_clearance)/2, center=true);
    }
    
    // Washer
    translate([0, 0, -thickness/2 - washer_thickness/2 + overlap]) {
      difference() {
        // Washer outer
        cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
        // Washer hole
        cylinder(h=washer_thickness + 2*overlap, r=(hole_diameter + tolerance_clearance)/2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();