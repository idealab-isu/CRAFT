// Parameters
thread_diameter = 8; //[4:16:0.1]
head_diameter = 14; //[7:28:0.1]
head_height = 4.4; //[2.2:8.8:0.1]
length_under_head = 10; //[5:20:0.1]
overlap = 1; //[0.5:2:0.1]
shaft_radius = 4; //[2:8:0.1]
head_radius = 7; //[3.5:14:0.1]
thread_ring_count = 8; //[4:20:1]
thread_ring_height = 0.6; //[0.3:1.2:0.1]
thread_ring_radial = 0.35; //[0.15:0.8:0.05]
washer_outer_diameter = 16; //[8:32:0.1]
washer_thickness = 1.2; //[0.6:2.4:0.1]
washer_clearance = 0.5; //[0.2:1:0.1]
spacer_height = 6; //[3:12:0.1]
spacer_wall = 1.8; //[0.9:3.6:0.1]
buzzer_radius = 6; //[3:12:0.1]
buzzer_height = 4; //[2:8:0.1]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=thread_diameter/2 + washer_clearance + spacer_wall, h=spacer_height, center=true);
      translate([0, 0, -overlap])
        cylinder(r=thread_diameter/2 + washer_clearance, h=spacer_height + overlap*2, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shaft
    translate([0, 0, -head_height/2 - length_under_head/2 + overlap])
      cylinder(r=shaft_radius, h=length_under_head, center=true);
    
    // Dome Head
    intersection() {
      translate([0, 0, head_diameter/2 - head_height/2])
        sphere(r=head_radius, center=true);
      translate([0, 0, head_height/2])
        cube([head_diameter*2, head_diameter*2, head_diameter], center=true);
    }
    translate([0, 0, head_height/2])
      cylinder(r=head_radius, h=head_height, center=true);
    
    // Thread Representation
    for (i = [0:thread_ring_count-1]) {
      translate([0, 0, -head_height - thread_ring_height/2 - (length_under_head - thread_ring_height) * (i + 0.5)/thread_ring_count])
        cylinder(r=shaft_radius + thread_ring_radial, h=thread_ring_height, center=true);
    }
    
    // Washer
    difference() {
      translate([0, 0, -washer_thickness/2 + overlap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
      translate([0, 0, -washer_thickness/2 + overlap])
        cylinder(r=shaft_radius + washer_clearance, h=washer_thickness + overlap*2, center=true);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, -washer_thickness - spacer_height - buzzer_height/2 + overlap])
      cylinder(r=buzzer_radius, h=buzzer_height, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  translate([0, 0, -washer_thickness - spacer_height/2 + overlap])
    pcb_spacer();
  buzzer();
}

assembly();