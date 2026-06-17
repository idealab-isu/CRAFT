// Parameters
screw_thread_diameter = 4.0; //[2.0:8.0:0.1]
screw_thread_pitch = 0.7; //[0.35:1.4:0.05]
across_flats = 6.0; //[3.0:12.0:0.1]
thickness = 3.7; //[1.85:7.4:0.1]
thread_tap_drill_diameter = 3.3; //[2.0:6.0:0.05]
thread_engagement_length = 3.7; //[1.85:7.4:0.1]
edge_chamfer = 0.2; //[0.1:0.8:0.05]
slot_clearance = 0.2; //[0.0:0.6:0.05]
corner_radius = 0.3; //[0.0:1.0:0.05]
nut_length = 12.0; //[6.0:24.0:0.5]
retention_width = 10.0; //[6.0:20.0:0.5]
retention_height = 1.2; //[0.6:2.4:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// T-slot nut body with hex profile
module t_slot_nut_body_hex() {
  color("DimGray") {
    cylinder(r=across_flats/(2*cos(30)), h=thickness, center=true, $fn=6);
  }
}

// Retention profile block
module t_slot_retention_profile_block() {
  color("Silver") {
    translate([0, 0, -thickness/2 - retention_height/2 + overlap])
      cube([nut_length, retention_width - 2*slot_clearance, retention_height], center=true);
  }
}

// Lead-in chamfers
module lead_in_chamfers() {
  color("Silver") {
    difference() {
      union() {
        t_slot_nut_body_hex();
        t_slot_retention_profile_block();
      }
      translate([nut_length/2 - edge_chamfer, 0, -retention_height/2 + overlap/2])
        cube([edge_chamfer*2, retention_width, thickness + retention_height + 2*edge_chamfer], center=true);
      translate([-nut_length/2 + edge_chamfer, 0, -retention_height/2 + overlap/2])
        cube([edge_chamfer*2, retention_width, thickness + retention_height + 2*edge_chamfer], center=true);
    }
  }
}

// Threaded hole for M4 screw
module threaded_hole_m4() {
  color("Black") {
    translate([0, 0, 0])
      cylinder(r=thread_tap_drill_diameter/2, h=thread_engagement_length + 2*overlap, center=true);
  }
}

// Nut and washer assembly
module nut_and_washer() {
  difference() {
    lead_in_chamfers();
    threaded_hole_m4();
  }
}

// Final assembly
module assembly() {
  nut_and_washer();
}

assembly();