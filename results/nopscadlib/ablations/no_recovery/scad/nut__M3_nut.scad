// Parameters
thread_diameter = 3; //[1.5:6:0.1]
thread_pitch = 0.5; //[0.25:1:0.05]
hole_style = 0; //[0:1:1]
hole_clearance = 0.2; //[0:0.6:0.05]
across_flats = 6.4; //[3.2:12.8:0.1]
thickness = 2.4; //[1.2:4.8:0.1]
chamfer_size = 0.2; //[0.1:0.8:0.05]
eps = 0.6; //[0.2:1.5:0.1]
washer_outer_diameter = 7; //[4:14:0.1]
washer_thickness = 0.8; //[0.4:2:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hex Nut Body
    difference() {
      cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true);
      // Central Thread Hole
      translate([0, 0, 0])
        cylinder(r=(thread_diameter + hole_clearance)/2, h=thickness + 2*eps, center=true);
      // Top Chamfer
      translate([0, 0, thickness/2 - (chamfer_size + eps)/2])
        cylinder(r1=across_flats/(2*cos(30)) + eps, r2=across_flats/(2*cos(30)) - chamfer_size, h=chamfer_size + eps, center=true);
      // Bottom Chamfer
      translate([0, 0, -thickness/2 + (chamfer_size + eps)/2])
        cylinder(r1=across_flats/(2*cos(30)) - chamfer_size, r2=across_flats/(2*cos(30)) + eps, h=chamfer_size + eps, center=true);
    }
    // Washer
    translate([0, 0, -thickness/2 - washer_thickness/2 + eps])
      difference() {
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
        cylinder(r=(thread_diameter + hole_clearance)/2, h=washer_thickness + 2*eps, center=true);
      }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();