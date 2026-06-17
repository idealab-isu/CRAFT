// Parameters
thread_diameter = 6; //[3:12:0.1]
across_flats = 7.7; //[4:15.4:0.1]
thickness = 7.9; //[4:15.8:0.1]
hole_type = 0; //[0:1:1]
clearance_hole_diameter = 6.2; //[6:7.5:0.05]
thread_pitch = 1; //[0.5:2:0.1]
tap_hole_diameter = 5; //[4:6:0.05]
chamfer_size = 0.3; //[0.1:1:0.05]
overlap = 0.8; //[0.5:2:0.1]
washer_outer_diameter = 14; //[8:28:0.1]
washer_thickness = 1.6; //[0.8:3.2:0.1]
washer_hole_diameter = 6.4; //[6.1:8:0.05]

// Hexagonal Nut with Washer
module nut_and_washer() {
  // Hex Nut Body
  difference() {
    color("DimGray") {
      cylinder(h=thickness, r=(across_flats/2)/cos(30), center=true, $fn=6);
    }
    // Central Through Hole
    cylinder(h=thickness + 2*overlap, r=((1-hole_type)*(clearance_hole_diameter/2) + hole_type*(tap_hole_diameter/2)), center=true);
    // Top and Bottom Chamfers
    union() {
      translate([0, 0, thickness/2 - (chamfer_size + overlap)/2])
        cylinder(h=chamfer_size + overlap, r1=(across_flats/2)/cos(30) + overlap, r2=0, center=true);
      translate([0, 0, -thickness/2 + (chamfer_size + overlap)/2])
        rotate([180, 0, 0])
        cylinder(h=chamfer_size + overlap, r1=(across_flats/2)/cos(30) + overlap, r2=0, center=true);
    }
  }
  
  // Washer
  difference() {
    color("Silver") {
      translate([0, 0, -thickness/2 - washer_thickness/2 + overlap])
        cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
    }
    translate([0, 0, -thickness/2 - washer_thickness/2 + overlap])
      cylinder(h=washer_thickness + 2*overlap, r=washer_hole_diameter/2, center=true);
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();