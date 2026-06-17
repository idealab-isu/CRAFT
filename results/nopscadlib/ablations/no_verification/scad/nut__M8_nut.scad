// Parameters
thread_diameter_mm = 8.0; //[4.0:16.0:0.1]
across_flats_mm = 15.0; //[7.5:30.0:0.1]
thickness_mm = 6.5; //[3.25:13.0:0.1]
hole_clearance_mm = 0.4; //[0.0:1.5:0.05]
hole_type_is_threaded = 0; //[0:1:1]
thread_pitch_mm = 1.25; //[0.5:2.5:0.05]
chamfer_mm = 0.6; //[0.2:1.5:0.05]
chamfer_angle_deg = 45; //[30:60:1]
eps_mm = 0.8; //[0.2:2.0:0.1]
washer_enabled = 1; //[0:1:1]
washer_outer_diameter_mm = 16.0; //[8.0:32.0:0.1]
washer_thickness_mm = 1.6; //[0.8:3.2:0.1]
washer_hole_clearance_mm = 0.6; //[0.0:2.0:0.05]
thread_representation_enabled = 0; //[0:1:1]
thread_groove_depth_mm = 0.25; //[0.1:0.6:0.05]
thread_groove_count = 18; //[6:48:1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Hex Nut Body
    difference() {
      cylinder(r=across_flats_mm/(2*cos(30)), h=thickness_mm, center=true, $fn=6);
      // Central Through Hole
      cylinder(r=(thread_diameter_mm + hole_clearance_mm*(1-hole_type_is_threaded))/2, h=thickness_mm + 2*eps_mm, center=true);
      // Chamfers
      translate([0, 0, thickness_mm/2 - chamfer_mm/2 + eps_mm/2])
        rotate([180, 0, 0])
        cylinder(r1=(thread_diameter_mm + hole_clearance_mm*(1-hole_type_is_threaded))/2 + chamfer_mm, r2=0, h=chamfer_mm, center=true);
      translate([0, 0, -thickness_mm/2 + chamfer_mm/2 - eps_mm/2])
        cylinder(r1=(thread_diameter_mm + hole_clearance_mm*(1-hole_type_is_threaded))/2 + chamfer_mm, r2=0, h=chamfer_mm, center=true);
    }
    
    // Washer
    if (washer_enabled) {
      translate([0, 0, -thickness_mm/2 - washer_thickness_mm/2 + eps_mm])
        difference() {
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
          cylinder(r=(thread_diameter_mm + washer_hole_clearance_mm)/2, h=washer_thickness_mm + 2*eps_mm, center=true);
        }
    }
  }
  
  // Thread Representation (optional)
  if (thread_representation_enabled) {
    difference() {
      union() {
        for (i = [0:thread_groove_count-1]) {
          rotate([0, 0, i*360/thread_groove_count])
            translate([(thread_diameter_mm + hole_clearance_mm*(1-hole_type_is_threaded))/2 - thread_groove_depth_mm/2, 0, 0])
            cube([thread_groove_depth_mm, (thread_diameter_mm + hole_clearance_mm*(1-hole_type_is_threaded)), thickness_mm + 2*eps_mm], center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();