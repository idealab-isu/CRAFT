// Parameters
thread_diameter = 2; //[1:4:0.1]
thread_pitch = 0.4; //[0.2:0.8:0.05]
across_flats = 4.9; //[2.45:9.8:0.05]
thickness = 1.6; //[0.8:3.2:0.05]
hole_style = 0; //[0:1:1]
clearance_extra = 0.2; //[0.05:0.6:0.05]
tap_minor_factor = 0.8; //[0.6:0.95:0.01]
chamfer_size = 0.15; //[0.05:0.4:0.01]
overlap = 0.5; //[0.2:2:0.1]
washer_enabled = 0; //[0:1:1]
washer_outer_diameter = 5; //[2.5:10:0.1]
washer_thickness = 0.5; //[0.25:1.5:0.05]

// Nut and Washer Module
module nut_and_washer() {
  // Hex Nut Body
  module hex_nut_body() {
    color("DimGray") {
      cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
    }
  }

  // Central Thread Hole
  module central_thread_hole() {
    cylinder(r=((thread_diameter*tap_minor_factor)*(1-hole_style) + (thread_diameter+clearance_extra)*hole_style)/2, 
             h=thickness + 2*overlap, center=true);
  }

  // Top and Bottom Edge Chamfer
  module top_bottom_edge_chamfer() {
    cylinder(r1=across_flats/(2*cos(30)) + overlap, 
             r2=across_flats/(2*cos(30)) - chamfer_size, 
             h=chamfer_size, center=true);
  }

  // Washer Outer
  module washer_outer() {
    color("Silver") {
      cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
    }
  }

  // Washer Inner Hole
  module washer_inner_hole() {
    cylinder(r=((thread_diameter*tap_minor_factor)*(1-hole_style) + (thread_diameter+clearance_extra)*hole_style)/2, 
             h=washer_thickness + 2*overlap, center=true);
  }

  // Nut with Chamfers
  module nut_with_chamfers() {
    difference() {
      hex_nut_body();
      central_thread_hole();
      translate([0, 0, thickness/2 - chamfer_size/2]) top_bottom_edge_chamfer();
      translate([0, 0, -thickness/2 + chamfer_size/2]) top_bottom_edge_chamfer();
    }
  }

  // Washer Minus Hole
  module washer_minus_hole() {
    difference() {
      washer_outer();
      washer_inner_hole();
    }
  }

  // Final Nut and Washer Assembly
  if (washer_enabled) {
    union() {
      nut_with_chamfers();
      translate([0, 0, -thickness/2 - washer_thickness/2 + overlap]) washer_minus_hole();
    }
  } else {
    nut_with_chamfers();
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();