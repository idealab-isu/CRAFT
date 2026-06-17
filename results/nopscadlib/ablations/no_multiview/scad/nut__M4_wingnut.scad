// Parameters
thread_diameter = 4.0; //[2.0:8.0:0.1]
thread_pitch = 0.7; //[0.35:1.4:0.05]
across_flats = 10.0; //[5.0:20.0:0.1]
thickness = 3.75; //[2.0:7.5:0.05]
thread_clearance = 0.2; //[0.0:0.6:0.05]
wing_count = 2; //[2:2:1]
wing_span_total = 24.0; //[12.0:48.0:0.5]
wing_length_from_hex = 7.0; //[3.5:14.0:0.25]
wing_height = 3.75; //[2.0:7.5:0.05]
wing_thickness = 2.5; //[1.2:5.0:0.1]
wing_tip_radius = 2.0; //[0.8:4.0:0.1]
wing_root_fillet_radius = 1.0; //[0.4:2.0:0.1]
hex_corner_chamfer = 0.3; //[0.0:1.0:0.05]
overlap = 0.8; //[0.2:2.0:0.1]
hole_extra_height = 2.0; //[0.5:6.0:0.5]

// Hex Nut Core
module hex_nut_core() {
  color("DimGray") {
    difference() {
      cylinder(h=thickness, r=across_flats/(2*cos(30)), center=true, $fn=6);
      translate([0, 0, -hole_extra_height/2])
        cylinder(h=thickness + hole_extra_height, r=(thread_diameter + thread_clearance)/2, center=true);
    }
  }
}

// Wing
module wing() {
  color("Silver") {
    union() {
      // Wing body
      translate([across_flats/2 + (wing_length_from_hex + wing_tip_radius*2)/2 - overlap, 0, 0])
        cube([wing_length_from_hex + wing_tip_radius*2, wing_thickness, wing_height], center=true);
      // Wing tip
      translate([across_flats/2 + wing_length_from_hex + wing_tip_radius - overlap, 0, 0])
        rotate([90, 0, 0])
        cylinder(h=wing_height, r=wing_tip_radius, center=true);
    }
  }
}

// Wing Root Fillet
module wing_root_fillet() {
  color("Silver") {
    hull() {
      translate([across_flats/2 - overlap, 0, 0])
        sphere(r=wing_root_fillet_radius, center=true);
      translate([across_flats/2 + wing_root_fillet_radius - overlap, 0, 0])
        sphere(r=wing_root_fillet_radius, center=true);
    }
  }
}

// Nut and Washer
module nut_and_washer() {
  union() {
    hex_nut_core();
    // Right wing
    translate([0, 0, 0]) {
      wing();
      wing_root_fillet();
    }
    // Left wing
    mirror([1, 0, 0]) {
      wing();
      wing_root_fillet();
    }
  }
}

// Edge Chamfers
module edge_chamfers() {
  difference() {
    nut_and_washer();
    // Top chamfer
    translate([0, 0, thickness/2 - hex_corner_chamfer])
      cylinder(h=hex_corner_chamfer*2, r1=across_flats/(2*cos(30)), r2=0, center=true, $fn=6);
    // Bottom chamfer
    translate([0, 0, -(thickness/2 - hex_corner_chamfer)])
      rotate([180, 0, 0])
      cylinder(h=hex_corner_chamfer*2, r1=across_flats/(2*cos(30)), r2=0, center=true, $fn=6);
  }
}

// Final Assembly
module assembly() {
  edge_chamfers();
}

assembly();