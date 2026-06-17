// Parameters
thread_diameter = 6.0; //[3.0:12.0:0.1]
across_flats = 10.0; //[6.0:20.0:0.1]
thickness = 3.2; //[1.6:6.4:0.1]
hole_type = 0; //[0:1:1]
thread_pitch = 1.0; //[0.5:2.0:0.05]
edge_chamfer = 0.2; //[0.0:0.8:0.05]
corner_radius = 0.0; //[0.0:1.0:0.05]
clearance_diameter = 6.6; //[6.1:7.2:0.05]
tap_drill_diameter = 5.0; //[4.2:5.5:0.05]
hole_extra_height = 2.0; //[0.5:6.0:0.5]
overlap = 0.8; //[0.5:2.0:0.1]
washer_outer_diameter = 12.0; //[8.0:24.0:0.1]
washer_thickness = 1.0; //[0.5:3.0:0.1]

// Hexagonal Nut with Chamfer
module hex_nut() {
  color("DimGray") {
    difference() {
      union() {
        // Hexagonal body
        cylinder(h=thickness, r=across_flats/(2*cos(30)), center=true, $fn=6);
        // Chamfer top and bottom
        translate([0, 0, thickness/2 - edge_chamfer/2 + overlap/2])
          cylinder(h=edge_chamfer, r1=across_flats/(2*cos(30)) + overlap, r2=0, center=true);
        translate([0, 0, -thickness/2 + edge_chamfer/2 - overlap/2])
          rotate([180, 0, 0])
          cylinder(h=edge_chamfer, r1=across_flats/(2*cos(30)) + overlap, r2=0, center=true);
      }
      // Central hole
      cylinder(h=thickness + hole_extra_height, r=((1-hole_type)*clearance_diameter + hole_type*tap_drill_diameter)/2, center=true);
    }
  }
}

// Washer
module washer() {
  color("Silver") {
    difference() {
      // Outer washer
      cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
      // Washer hole
      cylinder(h=washer_thickness + hole_extra_height, r=clearance_diameter/2, center=true);
    }
  }
}

// Nut and Washer Assembly
module nut_and_washer() {
  hex_nut();
  translate([0, 0, -thickness/2 - washer_thickness/2 + overlap])
    washer();
}

// Final Assembly
module assembly() {
  nut_and_washer();
}

assembly();