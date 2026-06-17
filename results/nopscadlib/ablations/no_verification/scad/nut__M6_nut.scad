// Parameters
thread_nominal_diameter_mm = 6; //[3:12:0.1]
thread_pitch_mm = 1; //[0.5:2:0.1]
hole_type = 1; //[0:1:1]
across_flats_mm = 11.5; //[6:23:0.1]
thickness_mm = 5; //[2.5:10:0.1]
chamfer_mm = 0.5; //[0.2:1.5:0.1]
eps_mm = 0.6; //[0.2:1.5:0.1]
hex_circumradius_mm = 6.639; //[3.3:13.3:0.001]
threaded_hole_diameter_mm = 5; //[4:6:0.1]
clearance_hole_diameter_mm = 6.6; //[6.2:7.2:0.1]
washer_outer_diameter_mm = 12; //[8:24:0.1]
washer_thickness_mm = 1.6; //[0.8:3.2:0.1]
washer_hole_diameter_mm = 6.6; //[6.2:7.2:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hex Nut Body
    difference() {
      cylinder(r=hex_circumradius_mm, h=thickness_mm, center=true, $fn=6);
      // Top and Bottom Chamfers
      union() {
        translate([0, 0, thickness_mm/2 - chamfer_mm/2])
          cylinder(r1=hex_circumradius_mm + eps_mm, r2=0, h=chamfer_mm + eps_mm, center=true);
        translate([0, 0, -thickness_mm/2 + chamfer_mm/2])
          rotate([180, 0, 0])
          cylinder(r1=hex_circumradius_mm + eps_mm, r2=0, h=chamfer_mm + eps_mm, center=true);
      }
      // Central Thread Hole
      cylinder(r=((hole_type*threaded_hole_diameter_mm + (1-hole_type)*clearance_hole_diameter_mm)/2), 
               h=thickness_mm + 2*eps_mm, center=true);
    }
  }
  
  color("Silver") {
    // Washer
    difference() {
      translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + eps_mm])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
      translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + eps_mm])
        cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();