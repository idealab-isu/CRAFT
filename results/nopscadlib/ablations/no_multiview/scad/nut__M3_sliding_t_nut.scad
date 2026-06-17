// Parameters
thread_diameter = 3.0; //[1.5:6.0:0.1]
thread_pitch = 0.5; //[0.25:1.0:0.05]
across_flats = 6.0; //[3.0:12.0:0.1]
thickness = 3.0; //[1.5:6.0:0.1]
hole_tap_drill_diameter = 2.5; //[1.2:5.0:0.05]
chamfer = 0.3; //[0.1:1.0:0.05]
edge_fillet_radius = 0.2; //[0.0:1.0:0.05]
t_slot_nominal_width = 8.0; //[4.0:16.0:0.1]
t_slot_neck_width = 6.0; //[3.0:12.0:0.1]
t_slot_depth = 6.0; //[3.0:12.0:0.1]
nut_overall_length = 10.0; //[5.0:20.0:0.1]
nut_overall_width = 7.8; //[4.0:16.0:0.1]
retention_feature_height = 0.8; //[0.3:2.0:0.05]
retention_feature_width = 0.8; //[0.3:2.0:0.05]
clearance_to_slot = 0.1; //[0.0:0.5:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
washer_outer_diameter = 7.0; //[4.0:14.0:0.1]
washer_thickness = 1.0; //[0.5:2.5:0.1]
washer_hole_diameter = 3.2; //[2.0:6.5:0.1]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // Nut Body
    intersection() {
      translate([0, 0, 0])
        cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true);
      translate([0, 0, 0])
        cube([nut_overall_length, nut_overall_width, thickness], center=true);
    }
    
    // Retention Ears
    union() {
      translate([0, nut_overall_width/2 + retention_feature_width/2 - overlap, -thickness/2 + retention_feature_height/2 - overlap])
        cube([nut_overall_length - 2*chamfer, retention_feature_width, retention_feature_height], center=true);
      translate([0, -nut_overall_width/2 - retention_feature_width/2 + overlap, -thickness/2 + retention_feature_height/2 - overlap])
        cube([nut_overall_length - 2*chamfer, retention_feature_width, retention_feature_height], center=true);
    }
    
    // Lead-in Chamfers
    difference() {
      translate([0, 0, 0])
        cube([nut_overall_length, nut_overall_width, thickness], center=true);
      translate([nut_overall_length/2 - chamfer/2, 0, 0])
        rotate([0, 0, 45])
        cube([chamfer, nut_overall_width + 2*retention_feature_width + 2*overlap, thickness + 2*overlap], center=true);
      translate([-nut_overall_length/2 + chamfer/2, 0, 0])
        rotate([0, 0, 45])
        cube([chamfer, nut_overall_width + 2*retention_feature_width + 2*overlap, thickness + 2*overlap], center=true);
    }
    
    // Threaded Hole
    translate([0, 0, 0])
      cylinder(r=hole_tap_drill_diameter/2, h=thickness + 2*overlap, center=true);
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, thickness/2 + washer_thickness/2 - overlap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
      translate([0, 0, thickness/2 + washer_thickness/2 - overlap])
        cylinder(r=washer_hole_diameter/2, h=washer_thickness + 2*overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();