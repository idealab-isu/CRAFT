// Parameters
thread_nominal_diameter = 5; //[2.5:10:0.1]
across_flats = 8; //[4:16:0.1]
thickness = 2.7; //[1.35:5.4:0.05]
thread_pitch = 0.8; //[0.35:1.6:0.05]
clearance_hole_diameter = 5.2; //[4.5:6.5:0.05]
thread_tap_drill_diameter = 4.2; //[3.2:5.0:0.05]
hole_mode = 0; //[0:1:1]
chamfer_size = 0.2; //[0.1:0.6:0.05]
eps = 0.6; //[0.2:1.5:0.1]

// Hex Nut with Chamfers and Central Hole
module nut_and_washer() {
  difference() {
    // Hex Nut Body
    color("DimGray") {
      cylinder(r=(across_flats/2)/cos(30), h=thickness, center=true, $fn=6);
    }
    // Top and Bottom Chamfers
    union() {
      translate([0, 0, thickness/2 - (chamfer_size+eps)/2 + eps/2])
        cylinder(r1=(across_flats/2)/cos(30) + eps, r2=0, h=chamfer_size + eps, center=true, $fn=6);
      translate([0, 0, -thickness/2 + (chamfer_size+eps)/2 - eps/2])
        rotate([180, 0, 0])
        cylinder(r1=(across_flats/2)/cos(30) + eps, r2=0, h=chamfer_size + eps, center=true, $fn=6);
    }
    // Central Thread Hole
    cylinder(r=((1-hole_mode)*clearance_hole_diameter + hole_mode*thread_tap_drill_diameter)/2, h=thickness + 2*eps, center=true);
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();