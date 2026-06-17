// Parameters
thread_major_diameter = 5; //[2.5:10:0.1]
overall_length = 10; //[5:20:0.1]
head_diameter = 9.5; //[5:19:0.1]
head_height = 2.75; //[1.4:5.5:0.05]
thread_length = 10; //[5:20:0.1]
shank_diameter = 5; //[2.5:10:0.1]
transition_height = 0.8; //[0.4:1.6:0.05]
transition_overlap = 0.8; //[0.5:2:0.1]
drive_socket_diameter = 4.5; //[2:7:0.1]
drive_socket_depth = 1.6; //[0.8:3.2:0.05]
washer_outer_diameter = 10; //[6:20:0.1]
washer_thickness = 1; //[0.5:2:0.05]
washer_hole_diameter = 5.5; //[3:11:0.1]
pcb_spacer_height = 6; //[3:12:0.1]
pcb_spacer_wall = 1.8; //[0.9:3.6:0.1]
pcb_spacer_clearance_diameter = 5.6; //[5.2:7:0.1]
buzzer_diameter = 12; //[6:24:0.1]
buzzer_height = 5; //[2.5:10:0.1]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=(pcb_spacer_clearance_diameter/2) + pcb_spacer_wall, h=pcb_spacer_height, center=true);
      translate([0, 0, 0])
        cylinder(r=pcb_spacer_clearance_diameter/2, h=pcb_spacer_height + transition_overlap*2, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Threaded Shaft
      translate([0, 0, -(thread_length/2)])
        cylinder(r=thread_major_diameter/2, h=thread_length, center=true);
      
      // Head to Shank Transition Chamfer
      translate([0, 0, transition_height/2 - transition_overlap])
        cylinder(r1=head_diameter/2, r2=shank_diameter/2, h=transition_height, center=true);
      
      // Dome Head
      difference() {
        union() {
          intersection() {
            translate([0, 0, head_height - head_diameter/2])
              sphere(r=head_diameter/2, center=true);
            translate([0, 0, head_height - head_diameter])
              cube([head_diameter*2, head_diameter*2, head_diameter*2], center=true);
          }
          translate([0, 0, head_height/2 - transition_overlap])
            cylinder(r=head_diameter/2, h=head_height, center=true);
        }
        translate([0, 0, head_height - drive_socket_depth/2])
          cylinder(r=drive_socket_diameter/2, h=drive_socket_depth, center=true);
      }
      
      // Washer
      difference() {
        translate([0, 0, -(thread_length + washer_thickness/2 - transition_overlap)])
          cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
        translate([0, 0, -(thread_length + washer_thickness/2 - transition_overlap)])
          cylinder(r=washer_hole_diameter/2, h=washer_thickness + transition_overlap*2, center=true);
      }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, -(thread_length + washer_thickness + pcb_spacer_height + buzzer_height/2 - transition_overlap)])
      cylinder(r=buzzer_diameter/2, h=buzzer_height, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, -(thread_length + washer_thickness + pcb_spacer_height/2 - transition_overlap)])
    pcb_spacer();
  buzzer();
}

assembly();