// Parameters
thread_diameter = 5; //[2.5:10:0.1]
thread_pitch = 0.8; //[0.4:1.6:0.05]
across_flats = 8; //[4:16:0.1]
thickness = 2.7; //[1.35:5.4:0.05]
chamfer = 0.2; //[0.1:0.6:0.05]
tolerance_hole_diameter = 0; //[-0.2:0.4:0.01]
overlap = 0.8; //[0.5:2:0.1]
washer_outer_diameter = 10; //[6:20:0.1]
washer_thickness = 1; //[0.5:2:0.05]
washer_hole_extra_diameter = 0.5; //[0.2:1.5:0.05]

// Hex Nut with Washer
module nut_and_washer() {
  color("DimGray") {
    union() {
      // Hex Nut Body
      difference() {
        translate([0, 0, 0])
          cylinder(h=thickness, r=(across_flats/2)/cos(30), center=true, $fn=6);
        // Central Threaded Hole
        translate([0, 0, 0])
          cylinder(h=thickness + 2*overlap, r=(thread_diameter + tolerance_hole_diameter)/2, center=true);
        // Top Face Chamfer Cut
        translate([0, 0, thickness/2 - (chamfer + overlap)/2])
          cylinder(h=chamfer + overlap, r1=(thread_diameter + tolerance_hole_diameter)/2 + chamfer, r2=0, center=true);
        // Bottom Face Chamfer Cut
        translate([0, 0, -thickness/2 + (chamfer + overlap)/2])
          rotate([180, 0, 0])
          cylinder(h=chamfer + overlap, r1=(thread_diameter + tolerance_hole_diameter)/2 + chamfer, r2=0, center=true);
      }
      // Washer
      difference() {
        translate([0, 0, -thickness/2 - washer_thickness/2 + overlap])
          cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
        translate([0, 0, -thickness/2 - washer_thickness/2 + overlap])
          cylinder(h=washer_thickness + 2*overlap, r=(thread_diameter + washer_hole_extra_diameter)/2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();