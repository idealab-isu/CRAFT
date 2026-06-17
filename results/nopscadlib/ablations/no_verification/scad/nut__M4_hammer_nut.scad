// Parameters
screw_thread_diameter = 4.0; //[2.0:8.0:0.1]
thread_pitch = 0.7; //[0.4:1.5:0.05]
pilot_hole_diameter_if_untapped = 3.3; //[2.0:6.0:0.05]
threaded_hole_diameter = 3.3; //[2.0:6.0:0.05]
across_flats = 6.0; //[3.0:12.0:0.1]
thickness = 3.25; //[1.6:6.5:0.05]
chamfer_size = 0.3; //[0.0:1.0:0.05]
clearance_fit = 0.1; //[0.0:0.5:0.05]
corner_radius = 0.2; //[0.0:1.0:0.05]
slot_width = 8.0; //[4.0:16.0:0.1]
slot_lip_opening = 6.0; //[3.0:12.0:0.1]
slot_depth = 6.0; //[3.0:12.0:0.1]
body_length_along_slot = 12.0; //[6.0:24.0:0.1]
body_width_across_slot = 7.8; //[4.0:16.0:0.1]
anti_rotation_wing_thickness = 0.8; //[0.3:2.0:0.05]
anti_rotation_wing_height = 1.2; //[0.5:3.0:0.05]
anti_rotation_wing_length = 6.0; //[3.0:12.0:0.1]
overlap = 0.8; //[0.2:2.0:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // T-slot nut body
    intersection() {
      translate([0, 0, 0])
        cube([body_length_along_slot, body_width_across_slot, thickness], center=true);
      translate([0, 0, 0])
        rotate([0, 0, 0])
        cylinder(h=thickness, r=across_flats/(2*cos(30)), center=true, $fn=6);
    }
    
    // Anti-rotation wings
    union() {
      translate([0, -(body_width_across_slot/2 + anti_rotation_wing_thickness/2 - overlap), (thickness/2 - anti_rotation_wing_height/2 + overlap)])
        cube([anti_rotation_wing_length, anti_rotation_wing_thickness, anti_rotation_wing_height], center=true);
      translate([0, (body_width_across_slot/2 + anti_rotation_wing_thickness/2 - overlap), (thickness/2 - anti_rotation_wing_height/2 + overlap)])
        cube([anti_rotation_wing_length, anti_rotation_wing_thickness, anti_rotation_wing_height], center=true);
    }
  }
  
  // Central threaded hole with chamfers
  difference() {
    translate([0, 0, 0])
      union() {
        cylinder(h=thickness + 2*overlap, r=threaded_hole_diameter/2, center=true, $fn=32);
        translate([0, 0, thickness/2 - chamfer_size/2 + overlap])
          cylinder(h=chamfer_size, r1=threaded_hole_diameter/2 + chamfer_size, r2=0, center=true, $fn=32);
        translate([0, 0, -(thickness/2 - chamfer_size/2 + overlap)])
          rotate([180, 0, 0])
          cylinder(h=chamfer_size, r1=threaded_hole_diameter/2 + chamfer_size, r2=0, center=true, $fn=32);
      }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();