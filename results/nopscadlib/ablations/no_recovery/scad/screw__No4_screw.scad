// Parameters
shaft_diameter = 3; //[1.5:6:0.1]
length_under_head = 10; //[5:20:0.5]
head_diameter = 5.5; //[2.75:11:0.1]
head_height = 2; //[1:4:0.1]
overlap = 0.8; //[0.2:2:0.1]
drive_enabled = 0; //[0:1:1]
drive_socket_radius = 1.2; //[0.6:2.4:0.1]
drive_socket_depth = 1; //[0.5:2:0.1]
thread_enabled = 0; //[0:1:1]
thread_minor_diameter = 2.6; //[1.3:5.2:0.1]
thread_length = 8; //[4:16:0.5]
washer_enabled = 0; //[0:1:1]
washer_outer_diameter = 7; //[3.5:14:0.1]
washer_thickness = 1; //[0.5:2:0.1]
spacer_enabled = 0; //[0:1:1]
spacer_height = 6; //[3:12:0.5]
spacer_wall = 1.8; //[0.9:3.6:0.1]
buzzer_enabled = 0; //[0:1:1]
buzzer_radius = 6; //[3:12:0.5]
buzzer_height = 4; //[2:8:0.5]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Shaft
    translate([0, 0, -head_height/2 - length_under_head/2 + overlap/2])
      cylinder(h=length_under_head, r=shaft_diameter/2, center=true);
    
    // Pan Head
    translate([0, 0, 0])
      cylinder(h=head_height, r=head_diameter/2, center=true);
    
    // Drive Recess (optional)
    if (drive_enabled) {
      translate([0, 0, head_height/2 - drive_socket_depth/2])
        cylinder(h=drive_socket_depth + overlap, r=drive_socket_radius, center=true);
    }
    
    // Thread Representation (optional)
    if (thread_enabled) {
      translate([0, 0, -head_height/2 - length_under_head + thread_length/2 + overlap/2])
        cylinder(h=thread_length, r=thread_minor_diameter/2, center=true);
    }
    
    // Washer (optional)
    if (washer_enabled) {
      difference() {
        translate([0, 0, -head_height/2 - washer_thickness/2 + overlap/2])
          cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
        translate([0, 0, -head_height/2 - washer_thickness/2 + overlap/2])
          cylinder(h=washer_thickness + 2*overlap, r=shaft_diameter/2 + overlap/2, center=true);
      }
    }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  if (spacer_enabled) {
    color("Silver") {
      difference() {
        translate([0, 0, -head_height/2 - washer_thickness - spacer_height/2 + overlap])
          cylinder(h=spacer_height, r=shaft_diameter/2 + spacer_wall, center=true);
        translate([0, 0, -head_height/2 - washer_thickness - spacer_height/2 + overlap])
          cylinder(h=spacer_height + 2*overlap, r=shaft_diameter/2 + overlap/2, center=true);
      }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  if (buzzer_enabled) {
    color("Black") {
      translate([0, 0, -head_height/2 - washer_thickness - spacer_height - buzzer_height/2 + overlap])
        cylinder(h=buzzer_height, r=buzzer_radius, center=true);
    }
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();