// Parameters
thread_major_diameter = 6.0; //[3.0:12.0:0.1]
overall_length = 10.0; //[5.0:20.0:0.1]
head_diameter = 10.5; //[6.0:21.0:0.1]
head_height = 3.3; //[1.6:6.6:0.1]
thread_length = 10.0; //[5.0:20.0:0.1]
drive_recess_diameter = 4.0; //[2.0:7.0:0.1]
drive_recess_depth = 1.8; //[0.8:3.0:0.1]
transition_height = 0.8; //[0.4:1.6:0.1]
transition_overlap = 0.8; //[0.5:2.0:0.1]
washer_outer_diameter = 12.0; //[8.0:24.0:0.1]
washer_thickness = 1.0; //[0.5:2.5:0.1]
pcb_spacer_height = 6.0; //[3.0:12.0:0.1]
pcb_spacer_wall = 1.8; //[0.9:3.6:0.1]
pcb_spacer_clearance = 0.4; //[0.2:0.8:0.1]
buzzer_diameter = 12.0; //[8.0:24.0:0.1]
buzzer_height = 5.0; //[3.0:10.0:0.1]
bridge_thickness = 1.2; //[0.6:2.4:0.1]
bridge_width = 3.0; //[1.5:6.0:0.1]
side_offset = 14.0; //[8.0:28.0:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Threaded Shaft
    translate([0, 0, -overall_length/2])
      cylinder(h=overall_length, r=thread_major_diameter/2, center=true);

    // Head Transition
    translate([0, 0, transition_height/2 - transition_overlap])
      cylinder(h=transition_height, r1=head_diameter/2, r2=thread_major_diameter/2, center=true);

    // Dome Head
    intersection() {
      translate([0, 0, head_height - ((head_diameter/2)^2 + head_height^2)/(2*head_height)])
        sphere(r=((head_diameter/2)^2 + head_height^2)/(2*head_height));
      translate([0, 0, head_height + ((head_diameter/2)^2 + head_height^2)/(2*head_height)])
        cube([head_diameter*3, head_diameter*3, ((head_diameter/2)^2 + head_height^2)/(2*head_height)*2], center=true);
    }

    // Drive Recess
    translate([0, 0, head_height - drive_recess_depth/2])
      difference() {
        cylinder(h=drive_recess_depth, r=drive_recess_diameter/2, center=true);
      }

    // Washer
    translate([0, 0, washer_thickness/2 - transition_overlap])
      cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      translate([side_offset, 0, -overall_length + pcb_spacer_height/2])
        cylinder(h=pcb_spacer_height, r=(thread_major_diameter/2 + pcb_spacer_clearance) + pcb_spacer_wall, center=true);
      translate([side_offset, 0, -overall_length + pcb_spacer_height/2])
        cylinder(h=pcb_spacer_height + transition_overlap*2, r=thread_major_diameter/2 + pcb_spacer_clearance, center=true);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([side_offset, 0, -overall_length + pcb_spacer_height + buzzer_height/2 - transition_overlap])
      cylinder(h=buzzer_height, r=buzzer_diameter/2, center=true);
  }
}

// Bridges
module bridges() {
  color("Silver") {
    // Bridge to Spacer
    translate([(side_offset + (thread_major_diameter/2 + pcb_spacer_clearance) + pcb_spacer_wall)/2, 0, -overall_length + bridge_thickness/2])
      cube([side_offset + (thread_major_diameter/2 + pcb_spacer_clearance) + pcb_spacer_wall, bridge_width, bridge_thickness], center=true);

    // Bridge Spacer to Buzzer
    translate([side_offset, 0, -overall_length + pcb_spacer_height + (buzzer_height - transition_overlap)/2])
      cube([bridge_thickness, bridge_width, buzzer_height + transition_overlap], center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
  bridges();
}

assembly();