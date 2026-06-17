// Parameters
thread_diameter = 3.0; //[1.5:6.0:0.1]
thread_pitch = 0.5; //[0.25:1.0:0.05]
across_flats = 5.5; //[3.0:11.0:0.1]
thickness = 1.8; //[0.9:3.6:0.1]
tolerance_hole_diameter = 0.0; //[-0.2:0.6:0.05]
hole_diameter = 3.0; //[2.5:3.6:0.05]
chamfer_top = 0.2; //[0.0:0.6:0.05]
chamfer_bottom = 0.2; //[0.0:0.6:0.05]
eps = 0.2; //[0.05:0.5:0.05]
hex_circumradius = 3.1754264805429417; //[1.5:6.5:0.01]
hole_radius = 1.5; //[1.0:2.0:0.01]
chamfer_outer_radius = 3.1754264805429417; //[1.5:6.5:0.01]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    difference() {
      // Hex Nut Body
      cylinder(r=hex_circumradius, h=thickness, center=true, $fn=6);
      
      // Central Threaded Hole
      translate([0, 0, 0])
        cylinder(r=hole_radius, h=thickness + 2*eps, center=true);
    }
    
    // Top Chamfer
    translate([0, 0, thickness/2 - (chamfer_top + eps)/2 + eps/2])
      rotate([180, 0, 0])
      cylinder(r1=chamfer_outer_radius, r2=0, h=chamfer_top + eps, center=true);
    
    // Bottom Chamfer
    translate([0, 0, -thickness/2 + (chamfer_bottom + eps)/2 - eps/2])
      cylinder(r1=chamfer_outer_radius, r2=0, h=chamfer_bottom + eps, center=true);
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();