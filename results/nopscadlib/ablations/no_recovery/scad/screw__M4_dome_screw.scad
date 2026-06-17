// Parameters
thread_diameter = 4.0; //[2.0:8.0:0.1]
length = 10.0; //[5.0:20.0:0.5]
head_diameter = 7.6; //[4.0:15.2:0.1]
head_height = 2.2; //[1.1:4.4:0.1]
socket_af = 2.5; //[1.5:4.0:0.1]
socket_depth = 1.6; //[0.8:3.2:0.1]
tip_length = 1.2; //[0.6:2.4:0.1]
thread_relief = 0.15; //[0.05:0.4:0.01]
overlap = 0.8; //[0.3:2.0:0.1]
washer_outer_diameter = 9.0; //[6.0:18.0:0.1]
washer_thickness = 0.8; //[0.4:2.0:0.1]
washer_hole_diameter = 4.4; //[4.1:6.0:0.1]
spacer_height = 6.0; //[3.0:12.0:0.5]
spacer_wall = 1.8; //[0.9:3.6:0.1]
spacer_clearance_diameter = 4.6; //[4.2:6.5:0.1]
buzzer_diameter = 12.0; //[6.0:24.0:0.5]
buzzer_height = 5.0; //[2.5:10.0:0.5]
buzzer_post_diameter = 4.2; //[3.0:6.0:0.1]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=spacer_clearance_diameter/2 + spacer_wall, h=spacer_height, center=true);
      translate([0, 0, -overlap])
        cylinder(r=spacer_clearance_diameter/2, h=spacer_height + overlap*2, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Threaded shaft
    translate([0, 0, -length/2])
      cylinder(r=thread_diameter/2 - thread_relief, h=length, center=true);
    // Tip end
    translate([0, 0, -length - tip_length/2 + overlap])
      cylinder(r1=thread_diameter/2 - thread_relief, r2=0, h=tip_length, center=true);
    // Dome head
    intersection() {
      translate([0, 0, head_diameter/2 - head_height])
        sphere(r=head_diameter/2, center=true);
      translate([0, 0, head_height/2])
        cube([head_diameter*2, head_diameter*2, head_height], center=true);
    }
    // Hex socket recess
    translate([0, 0, head_height - socket_depth/2])
      rotate([0, 0, 0])
      cylinder(r=socket_af/(2*cos(30)), h=socket_depth, center=true);
  }
  color("Silver") {
    // Washer
    difference() {
      translate([0, 0, -washer_thickness/2 + overlap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
      translate([0, 0, -washer_thickness/2 + overlap])
        cylinder(r=washer_hole_diameter/2, h=washer_thickness + overlap*2, center=true);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    // Buzzer body
    translate([0, 0, -washer_thickness - spacer_height - buzzer_height/2 + overlap])
      cylinder(r=buzzer_diameter/2, h=buzzer_height, center=true);
    // Buzzer post
    translate([0, 0, -washer_thickness - spacer_height/2 + overlap])
      cylinder(r=buzzer_post_diameter/2, h=spacer_height, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, -washer_thickness - spacer_height/2 + overlap])
    pcb_spacer();
  translate([0, 0, -washer_thickness - spacer_height - buzzer_height/2 + overlap])
    buzzer();
}

assembly();