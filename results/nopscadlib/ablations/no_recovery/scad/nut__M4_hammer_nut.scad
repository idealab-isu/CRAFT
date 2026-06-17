// Parameters
screw_thread_diameter = 4.0; //[2.0:8.0:0.1]
thread_pitch = 0.7; //[0.5:1.25:0.05]
across_flats = 6.0; //[3.0:12.0:0.1]
thickness = 3.25; //[1.6:6.5:0.05]
t_slot_nut_length = 10.0; //[6.0:20.0:0.5]
t_slot_channel_width = 8.0; //[5.0:12.0:0.5]
t_slot_lip_undercut = 1.0; //[0.5:2.5:0.1]
corner_chamfer = 0.2; //[0.0:1.0:0.05]
edge_fillet_radius = 0.0; //[0.0:1.5:0.1]
threaded_hole_type = 0; //[0:1:1]
thread_clearance = 0.3; //[0.0:0.8:0.05]
retention_wing_thickness = 1.2; //[0.6:2.4:0.1]
retention_wing_height_offset = 0.0; //[-0.8:0.8:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
washer_outer_diameter = 9.0; //[6.0:18.0:0.5]
washer_thickness = 1.0; //[0.5:2.5:0.1]
nut_and_washer_gap = 0.0; //[0.0:5.0:0.5]

// Nut and Washer - complete geometry
module nut_and_washer() {
  color("DimGray") {
    // T-slot nut body
    intersection() {
      // Hex outer profile
      translate([0, 0, 0])
        cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
      // T-slot nut body block
      translate([0, 0, 0])
        cube([t_slot_nut_length, 2*(across_flats/(2*cos(30))), thickness], center=true);
    }
    
    // Retention wings
    union() {
      translate([0, -(across_flats/2 + t_slot_lip_undercut/2 - overlap), retention_wing_height_offset])
        cube([t_slot_nut_length, t_slot_lip_undercut, retention_wing_thickness], center=true);
      translate([0, (across_flats/2 + t_slot_lip_undercut/2 - overlap), retention_wing_height_offset])
        cube([t_slot_nut_length, t_slot_lip_undercut, retention_wing_thickness], center=true);
    }
    
    // Lead-in chamfers
    difference() {
      translate([0, 0, 0])
        cube([t_slot_nut_length, 2*(across_flats/(2*cos(30))), thickness], center=true);
      translate([t_slot_nut_length/2 - corner_chamfer/2, 0, 0])
        cube([corner_chamfer, 2*(across_flats/(2*cos(30))), thickness + 2*overlap], center=true);
      translate([-(t_slot_nut_length/2 - corner_chamfer/2), 0, 0])
        cube([corner_chamfer, 2*(across_flats/(2*cos(30))), thickness + 2*overlap], center=true);
    }
    
    // Threaded hole
    difference() {
      translate([0, 0, 0])
        cylinder(r=(screw_thread_diameter + thread_clearance)/2, h=thickness + 2*overlap, center=true);
    }
  }
  
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, thickness/2 + washer_thickness/2 - overlap + nut_and_washer_gap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
      translate([0, 0, thickness/2 + washer_thickness/2 - overlap + nut_and_washer_gap])
        cylinder(r=(screw_thread_diameter + thread_clearance)/2, h=washer_thickness + 2*overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();