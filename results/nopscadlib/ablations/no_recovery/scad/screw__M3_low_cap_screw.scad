// Parameters
shaft_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 5.5; //[3:11:0.1]
head_height_mm = 2; //[1:4:0.1]
socket_af_mm = 2.5; //[1.5:4:0.1]
socket_depth_mm = 1.4; //[0.8:2.2:0.1]
thread_major_diameter_mm = 3; //[1.5:6:0.1]
thread_minor_diameter_mm = 2.6; //[1.2:5.2:0.1]
thread_pitch_mm = 0.5; //[0.25:1:0.05]
thread_turns = 12; //[4:40:1]
thread_ring_thickness_mm = 0.25; //[0.1:0.6:0.05]
overlap_mm = 0.8; //[0.5:2:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shaft
    translate([0, 0, -head_height_mm/2])
      cylinder(h=length_mm - head_height_mm, r=shaft_diameter_mm/2, center=true);
    
    // Cap Head
    translate([0, 0, (length_mm - head_height_mm)/2])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);
    
    // Hex Socket
    translate([0, 0, (length_mm - head_height_mm)/2 + head_height_mm/2 - socket_depth_mm/2 + overlap_mm/2])
      rotate([0, 0, 0])
      cylinder(h=socket_depth_mm, r=(socket_af_mm/2)/cos(30), center=true);
    
    // Cosmetic Thread Rings
    for (i = [0:thread_turns-1]) {
      translate([0, 0, -head_height_mm/2 - (length_mm - head_height_mm)/2 + thread_pitch_mm*i])
        cylinder(h=thread_ring_thickness_mm, r=thread_major_diameter_mm/2, center=true);
    }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    // Spacer Body
    difference() {
      cylinder(h=5, r=4, center=true);
      translate([0, 0, -2.5]) cylinder(h=5, r=2.2, center=true);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    // Buzzer Body
    cylinder(h=5, r=7, center=true);
    // Buzzer Top
    translate([0, 0, 2.5]) cylinder(h=1, r=6, center=true);
  }
}

// Pin Socket - complete geometry
module pin_socket() {
  color("Gold") {
    // Pin Socket Body
    cube([2, 2, 5], center=true);
    // Pin
    translate([0, 0, 2.5]) cylinder(h=5, r=0.5, center=true);
  }
}

// Assembly
module assembly() {
  translate([0, 0, 0]) screw_and_washer();
  translate([0, 0, length_mm/2 + 2.5]) pcb_spacer();
  translate([0, 0, length_mm/2 + 7.5]) buzzer();
  translate([0, 0, length_mm/2 + 12.5]) pin_socket();
}

assembly();