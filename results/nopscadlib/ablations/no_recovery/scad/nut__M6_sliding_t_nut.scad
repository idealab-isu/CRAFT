// Parameters
screw_thread_diameter = 6; //[3:12:0.1]
thread_pitch = 1; //[0.5:2:0.1]
across_flats = 8; //[4:16:0.1]
thickness = 6.6; //[3.3:13.2:0.1]
thread_tap_drill_diameter = 5; //[2.5:10:0.1]
thread_clearance_diameter = 6.6; //[3.3:13.2:0.1]
chamfer = 0.3; //[0.1:1.2:0.1]
fillet_radius = 0.5; //[0.2:2:0.1]
t_slot_clearance = 0.2; //[0.05:0.6:0.05]
t_slot_width = 13; //[8:26:0.1]
t_slot_neck_width = 8.5; //[5:17:0.1]
t_slot_depth = 7; //[4:14:0.1]
t_slot_lip_height = 1.2; //[0.6:2.4:0.1]
overlap = 0.8; //[0.5:2:0.1]
washer_outer_diameter = 12; //[6:24:0.1]
washer_thickness = 1.6; //[0.8:3.2:0.1]
washer_hole_diameter = 6.6; //[3.3:13.2:0.1]
assembly_gap = 0.6; //[0.2:2:0.1]

// Hex profile for nut body
module hex_profile_across_flats_8mm() {
  color("DimGray") {
    cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
  }
}

// T-slot retention lips
module t_slot_retention_lip_left() {
  color("DimGray") {
    translate([-(t_slot_neck_width/2 + ((t_slot_width - t_slot_neck_width)/2 - t_slot_clearance)/2 - overlap), 0, -(thickness/2 - t_slot_lip_height/2 - overlap)])
      cube([(t_slot_width - t_slot_neck_width)/2 - t_slot_clearance, across_flats - 2*t_slot_clearance, t_slot_lip_height], center=true);
  }
}

module t_slot_retention_lip_right() {
  color("DimGray") {
    translate([(t_slot_neck_width/2 + ((t_slot_width - t_slot_neck_width)/2 - t_slot_clearance)/2 - overlap), 0, -(thickness/2 - t_slot_lip_height/2 - overlap)])
      cube([(t_slot_width - t_slot_neck_width)/2 - t_slot_clearance, across_flats - 2*t_slot_clearance, t_slot_lip_height], center=true);
  }
}

// Threaded hole
module threaded_hole_m6() {
  color("Black") {
    cylinder(r=thread_tap_drill_diameter/2, h=thickness + 2*overlap, center=true);
  }
}

// Lead-in chamfers
module lead_in_chamfer_top() {
  color("Black") {
    translate([0, 0, thickness/2 - chamfer/2 + overlap])
      cylinder(r1=thread_tap_drill_diameter/2 + chamfer, r2=thread_tap_drill_diameter/2, h=chamfer, center=true);
  }
}

module lead_in_chamfer_bottom() {
  color("Black") {
    translate([0, 0, -(thickness/2 - chamfer/2 + overlap)])
      cylinder(r1=thread_tap_drill_diameter/2 + chamfer, r2=thread_tap_drill_diameter/2, h=chamfer, center=true);
  }
}

// Washer
module washer_outer() {
  color("Silver") {
    translate([0, 0, thickness/2 + assembly_gap + washer_thickness/2 - overlap])
      cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
  }
}

module washer_hole() {
  color("Black") {
    translate([0, 0, thickness/2 + assembly_gap + washer_thickness/2 - overlap])
      cylinder(r=washer_hole_diameter/2, h=washer_thickness + 2*overlap, center=true);
  }
}

// T-slot nut body
module t_slot_nut_body() {
  union() {
    hex_profile_across_flats_8mm();
    t_slot_retention_lip_left();
    t_slot_retention_lip_right();
  }
}

// T-slot nut body with thread and chamfers
module t_slot_nut_body_with_thread_and_chamfers() {
  difference() {
    t_slot_nut_body();
    threaded_hole_m6();
    lead_in_chamfer_top();
    lead_in_chamfer_bottom();
  }
}

// Washer solid
module washer_solid() {
  difference() {
    washer_outer();
    washer_hole();
  }
}

// Nut and washer assembly
module nut_and_washer() {
  union() {
    t_slot_nut_body_with_thread_and_chamfers();
    washer_solid();
  }
}

// Final assembly
module assembly() {
  nut_and_washer();
}

assembly();