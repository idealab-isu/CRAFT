// Parameters
shaft_diameter_mm = 2.0; //[1.0:4.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 3.5; //[2.0:7.0:0.1]
head_height_mm = 1.3; //[0.7:2.6:0.05]
socket_diameter_mm = 1.2; //[0.6:2.4:0.05]
socket_depth_mm = 0.7; //[0.3:1.3:0.05]
threaded_enabled = 0; //[0:1:1]
thread_diameter_mm = 2.0; //[1.0:4.0:0.1]
thread_length_mm = 7.0; //[3.0:18.0:0.5]
pcb_spacer_enabled = 0; //[0:1:1]
pcb_spacer_height_mm = 3.0; //[1.5:6.0:0.5]
pcb_spacer_wall_mm = 1.0; //[0.6:2.0:0.1]
pcb_spacer_clearance_mm = 0.2; //[0.1:0.5:0.05]
washer_enabled = 0; //[0:1:1]
washer_outer_diameter_mm = 5.0; //[3.0:10.0:0.1]
washer_thickness_mm = 0.5; //[0.2:1.5:0.05]
washer_clearance_mm = 0.3; //[0.1:0.8:0.05]
buzzer_enabled = 0; //[0:1:1]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 6.0; //[3.0:12.0:0.5]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shaft
    translate([0, 0, -head_height_mm/2])
      cylinder(h=length_mm - head_height_mm, r=shaft_diameter_mm/2, center=true);

    // Dome Head
    intersection() {
      translate([0, 0, length_mm/2 - head_height_mm + head_diameter_mm/2])
        sphere(r=head_diameter_mm/2, center=true);
      translate([0, 0, length_mm/2 - head_height_mm/2])
        cube([head_diameter_mm*2, head_diameter_mm*2, head_height_mm], center=true);
    }

    // Drive Socket Recess
    translate([0, 0, length_mm/2 - socket_depth_mm/2])
      cylinder(h=socket_depth_mm, r=socket_diameter_mm/2, center=true);
  }

  if (washer_enabled) {
    color("Silver") {
      // Washer
      difference() {
        translate([0, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm])
          cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
        translate([0, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm])
          cylinder(h=washer_thickness_mm + overlap_mm*2, r=shaft_diameter_mm/2 + washer_clearance_mm, center=true);
      }
    }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  if (pcb_spacer_enabled) {
    color("Silver") {
      difference() {
        translate([0, 0, length_mm/2 - head_height_mm - pcb_spacer_height_mm/2 + overlap_mm])
          cylinder(h=pcb_spacer_height_mm, r=shaft_diameter_mm/2 + pcb_spacer_clearance_mm + pcb_spacer_wall_mm, center=true);
        translate([0, 0, length_mm/2 - head_height_mm - pcb_spacer_height_mm/2 + overlap_mm])
          cylinder(h=pcb_spacer_height_mm + overlap_mm*2, r=shaft_diameter_mm/2 + pcb_spacer_clearance_mm, center=true);
      }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  if (buzzer_enabled) {
    color("Black") {
      translate([buzzer_diameter_mm/2 + washer_outer_diameter_mm/2 - overlap_mm, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm])
        cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true);
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