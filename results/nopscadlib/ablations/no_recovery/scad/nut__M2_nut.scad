// Parameters
thread_diameter_mm = 2; //[1:4:0.1]
across_flats_mm = 4.9; //[2.45:9.8:0.1]
thickness_mm = 1.6; //[0.8:3.2:0.1]
hole_type = 0; //[0:1:1]
thread_pitch_mm = 0.4; //[0.2:1:0.05]
chamfer_mm = 0; //[0:0.6:0.05]
corner_fillet_mm = 0; //[0:0.6:0.05]
overlap_mm = 0.8; //[0.2:2:0.1]
hex_circumradius_mm = 2.829; //[1.4145:5.658:0.001]
hole_diameter_clearance_mm = 2.2; //[2:2.6:0.05]
hole_diameter_tapped_mm = 1.6; //[1.2:2:0.05]
washer_outer_diameter_mm = 6; //[3:12:0.1]
washer_thickness_mm = 0.6; //[0.3:1.2:0.05]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hex Nut Body
    difference() {
      cylinder(r=hex_circumradius_mm, h=thickness_mm, center=true, $fn=6);
      // Central Thread or Clearance Hole
      cylinder(r=((1-hole_type)*(hole_diameter_clearance_mm/2) + hole_type*(hole_diameter_tapped_mm/2)), 
               h=thickness_mm + 2*overlap_mm, center=true);
    }
    
    // Washer Ring
    translate([0, 0, -(thickness_mm/2 + washer_thickness_mm/2 - overlap_mm)]) {
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        cylinder(r=((1-hole_type)*(hole_diameter_clearance_mm/2) + hole_type*(hole_diameter_tapped_mm/2)), 
                 h=washer_thickness_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();