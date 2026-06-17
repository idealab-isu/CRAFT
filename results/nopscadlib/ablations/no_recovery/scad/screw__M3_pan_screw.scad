// Parameters
shank_diameter = 3; //[1.5:6:0.1]
shank_radius = 1.5; //[0.75:3:0.05]
length_under_head = 10; //[5:20:0.5]
head_diameter = 5.4; //[3:10.8:0.1]
head_radius = 2.7; //[1.5:5.4:0.05]
head_height = 2; //[1:4:0.1]
overall_length = 12; //[6:24:0.5]
threaded = 1; //[0:1:1]
thread_pitch = 0.5; //[0.35:1:0.05]
thread_depth = 0.15; //[0.05:0.35:0.01]
thread_turns = 12; //[6:30:1]
drive_recess = 1; //[0:1:1]
recess_radius = 1.6; //[0.8:3.2:0.05]
recess_depth = 1; //[0.4:1.6:0.05]
recess_slot_width = 0.6; //[0.3:1.2:0.05]
overlap = 0.8; //[0.5:2:0.1]
washer_outer_diameter = 7; //[5:14:0.1]
washer_thickness = 0.8; //[0.4:2:0.05]
spacer_height = 6; //[3:12:0.5]
spacer_wall = 1.8; //[0.9:3.6:0.1]
buzzer_diameter = 12; //[6:24:0.5]
buzzer_height = 5; //[2.5:10:0.5]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      cylinder(r=shank_radius + spacer_wall, h=spacer_height, center=true);
      translate([0, 0, -overlap])
        cylinder(r=shank_radius + 0.2, h=spacer_height + 2*overlap, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw Head
      translate([0, 0, head_height/2])
        cylinder(r=head_radius, h=head_height, center=true);
      
      // Screw Shank
      translate([0, 0, -length_under_head/2])
        cylinder(r=shank_radius, h=length_under_head, center=true);
      
      // Drive Recess
      if (drive_recess) {
        difference() {
          translate([0, 0, head_height/2 - recess_depth/2])
            union() {
              cube([2*recess_radius, recess_slot_width, recess_depth], center=true);
              cube([recess_slot_width, 2*recess_radius, recess_depth], center=true);
            }
        }
      }
      
      // Washer
      translate([0, 0, -head_height/2 - washer_thickness/2 + overlap/2])
        difference() {
          cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
          translate([0, 0, -overlap])
            cylinder(r=shank_radius + 0.2, h=washer_thickness + 2*overlap, center=true);
        }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([0, 0, -head_height/2 - length_under_head - spacer_height - buzzer_height/2 + overlap])
      cylinder(r=buzzer_diameter/2, h=buzzer_height, center=true);
  }
}

// Thread Representation
module thread_representation() {
  if (threaded) {
    color("Silver") {
      for (i = [0:thread_turns-1]) {
        translate([0, 0, -head_height/2 - length_under_head + thread_pitch/2 + i*thread_pitch])
          rotate_extrude() translate([shank_radius - thread_depth/2, 0])
            circle(r=thread_depth/2);
      }
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
  thread_representation();
}

assembly();