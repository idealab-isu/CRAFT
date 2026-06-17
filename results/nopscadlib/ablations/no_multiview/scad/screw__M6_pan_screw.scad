// Parameters
shaft_diameter_mm = 6.0; //[3.0:12.0:0.1]
length_under_head_mm = 10.0; //[5.0:20.0:0.1]
head_diameter_mm = 12.0; //[6.0:24.0:0.1]
head_height_mm = 4.75; //[2.375:9.5:0.05]
drive_socket_radius_factor = 0.6; //[0.4:0.8:0.01]
drive_socket_depth_factor = 0.5; //[0.2:0.8:0.01]
drive_slot_width_mm = 1.0; //[0.5:2.5:0.1]
thread_major_diameter_factor = 1.06; //[1.0:1.15:0.01]
thread_pitch_mm = 1.0; //[0.5:2.0:0.1]
thread_depth_mm = 0.35; //[0.15:0.8:0.05]
thread_start_offset_mm = 0.5; //[0.0:2.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
washer_outer_diameter_mm = 14.0; //[10.0:28.0:0.1]
washer_thickness_mm = 1.2; //[0.6:3.0:0.1]
spacer_height_mm = 8.0; //[4.0:16.0:0.1]
spacer_outer_diameter_mm = 10.0; //[7.0:20.0:0.1]
buzzer_diameter_mm = 12.0; //[8.0:24.0:0.1]
buzzer_height_mm = 7.0; //[4.0:14.0:0.1]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Screw Shaft
    translate([0, 0, -head_height_mm/2 - length_under_head_mm/2 + overlap_mm])
      cylinder(h=length_under_head_mm, r=shaft_diameter_mm/2, center=true);

    // Pan Head
    translate([0, 0, 0])
      difference() {
        cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);
        // Drive Recess
        intersection() {
          cylinder(h=head_height_mm*drive_socket_depth_factor, r=(head_diameter_mm/2)*drive_socket_radius_factor, center=true);
          union() {
            translate([0, 0, head_height_mm/2 - (head_height_mm*drive_socket_depth_factor)/2])
              cube([(head_diameter_mm/2)*drive_socket_radius_factor*2, drive_slot_width_mm, head_height_mm*drive_socket_depth_factor], center=true);
            translate([0, 0, head_height_mm/2 - (head_height_mm*drive_socket_depth_factor)/2])
              cube([drive_slot_width_mm, (head_diameter_mm/2)*drive_socket_radius_factor*2, head_height_mm*drive_socket_depth_factor], center=true);
          }
        }
      }

    // Thread Representation
    translate([0, 0, -head_height_mm/2 - (length_under_head_mm - thread_start_offset_mm)/2 + overlap_mm - thread_start_offset_mm/2])
      difference() {
        cylinder(h=length_under_head_mm - thread_start_offset_mm, r=(shaft_diameter_mm/2)*thread_major_diameter_factor, center=true);
        cylinder(h=length_under_head_mm - thread_start_offset_mm + overlap_mm*2, r=(shaft_diameter_mm/2)*thread_major_diameter_factor - thread_depth_mm, center=true);
      }

    // Washer
    translate([0, 0, -head_height_mm/2 - washer_thickness_mm/2 + overlap_mm])
      difference() {
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
        cylinder(h=washer_thickness_mm + overlap_mm*2, r=shaft_diameter_mm/2 + overlap_mm/2, center=true);
      }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    translate([0, 0, -head_height_mm/2 - washer_thickness_mm - spacer_height_mm/2 + overlap_mm])
      difference() {
        cylinder(h=spacer_height_mm, r=spacer_outer_diameter_mm/2, center=true);
        cylinder(h=spacer_height_mm + overlap_mm*2, r=shaft_diameter_mm/2 + overlap_mm/2, center=true);
      }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([0, 0, -head_height_mm/2 - washer_thickness_mm - spacer_height_mm - buzzer_height_mm/2 + overlap_mm])
      cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();