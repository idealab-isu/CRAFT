// Parameters
thread_nominal_diameter = 5; //[2.5:10:0.1]
across_flats = 8; //[4:16:0.1]
thickness = 2.7; //[1.35:5.4:0.05]
hole_type = 0; //[0:1:1]
thread_pitch = 0.8; //[0.4:1.6:0.05]
hole_diameter_if_clearance = 5.5; //[5:7:0.05]
chamfer_size = 0.3; //[0:1:0.05]
corner_radius = 0; //[0:1:0.05]
eps = 0.2; //[0.05:0.5:0.05]
washer_outer_diameter = 10; //[6:20:0.1]
washer_thickness = 1; //[0.5:2:0.05]
washer_overlap = 0.6; //[0.2:1.5:0.05]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    difference() {
      union() {
        // Hex Nut Body
        translate([0, 0, 0])
          cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
        
        // Washer Ring
        difference() {
          translate([0, 0, -thickness/2 - washer_thickness/2 + washer_overlap])
            cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
          translate([0, 0, -thickness/2 - washer_thickness/2 + washer_overlap])
            cylinder(r=((1-hole_type)*hole_diameter_if_clearance + hole_type*thread_nominal_diameter)/2, h=washer_thickness + 2*eps, center=true);
        }
      }
      
      // Central Hole
      translate([0, 0, 0])
        cylinder(r=((1-hole_type)*hole_diameter_if_clearance + hole_type*thread_nominal_diameter)/2, h=thickness + 2*eps, center=true);
      
      // Edge Chamfer or Lead-in Top
      translate([0, 0, thickness/2 - chamfer_size/2 + eps/2])
        cylinder(r1=((1-hole_type)*hole_diameter_if_clearance + hole_type*thread_nominal_diameter)/2 + chamfer_size, r2=0, h=chamfer_size, center=true);
      
      // Edge Chamfer or Lead-in Bottom
      translate([0, 0, -thickness/2 + chamfer_size/2 - eps/2])
        cylinder(r1=((1-hole_type)*hole_diameter_if_clearance + hole_type*thread_nominal_diameter)/2 + chamfer_size, r2=0, h=chamfer_size, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();