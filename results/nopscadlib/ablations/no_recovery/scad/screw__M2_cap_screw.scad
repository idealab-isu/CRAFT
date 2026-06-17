// Parameters
shaft_diameter_mm = 2.0; //[1.0:4.0:0.1]
length_under_head_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 3.8; //[2.0:7.6:0.1]
head_height_mm = 2.0; //[1.0:4.0:0.1]
socket_across_flats_mm = 1.5; //[1.0:3.0:0.05]
socket_depth_mm = 1.2; //[0.6:1.8:0.05]
threaded = 1; //[0:1:1]
thread_pitch_mm = 0.4; //[0.2:0.8:0.05]
thread_length_mm = 10.0; //[5.0:20.0:0.5]
underhead_chamfer_height_mm = 0.4; //[0.2:1.0:0.05]
underhead_chamfer_radial_mm = 0.4; //[0.2:1.0:0.05]
overlap_mm = 0.8; //[0.5:2.0:0.1]
thread_representation_ridge_depth_mm = 0.15; //[0.05:0.3:0.01]
thread_representation_ridge_width_mm = 0.25; //[0.1:0.6:0.01]
thread_representation_ridge_count = 12; //[0:36:1]
washer_outer_diameter_mm = 5.0; //[3.0:10.0:0.1]
washer_thickness_mm = 0.6; //[0.3:1.5:0.05]
pcb_spacer_height_mm = 6.0; //[3.0:15.0:0.5]
pcb_spacer_wall_mm = 1.8; //[0.8:3.6:0.1]
sprue_diameter_mm = 1.2; //[0.8:3.0:0.1]
sprue_length_mm = 12.0; //[6.0:30.0:1]
buzzer_diameter_mm = 12.0; //[6.0:24.0:0.5]
buzzer_height_mm = 5.0; //[2.5:12.0:0.5]
pin_socket_width_mm = 8.0; //[4.0:16.0:0.5]
pin_socket_depth_mm = 3.0; //[1.5:8.0:0.5]
pin_socket_height_mm = 6.0; //[3.0:15.0:0.5]

// Screw and Washer
module screw_and_washer() {
  color("DimGray") {
    // Threaded Shaft
    translate([0, 0, -head_height_mm/2 - length_under_head_mm/2 + overlap_mm])
      cylinder(h=length_under_head_mm, r=shaft_diameter_mm/2, center=true);

    // Cap Head
    translate([0, 0, 0])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);

    // Underhead Chamfer
    translate([0, 0, -head_height_mm/2 + underhead_chamfer_height_mm/2])
      difference() {
        cylinder(h=underhead_chamfer_height_mm, r1=head_diameter_mm/2 + underhead_chamfer_radial_mm, r2=shaft_diameter_mm/2, center=true);
        cylinder(h=underhead_chamfer_height_mm, r=shaft_diameter_mm/2, center=true);
      }

    // Hex Socket Recess
    translate([0, 0, head_height_mm/2 - socket_depth_mm/2])
      cylinder(h=socket_depth_mm, r=socket_across_flats_mm/(2*cos(30)), center=true);

    // Washer
    translate([0, 0, -head_height_mm/2 - washer_thickness_mm/2 + overlap_mm])
      difference() {
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
        cylinder(h=washer_thickness_mm + overlap_mm*2, r=shaft_diameter_mm/2 + overlap_mm/4, center=true);
      }
  }
}

// PCB Spacer
module pcb_spacer() {
  color("Silver") {
    translate([head_diameter_mm/2 + sprue_length_mm + (shaft_diameter_mm/2 + pcb_spacer_wall_mm) - overlap_mm, 0, -head_height_mm/2 - pcb_spacer_height_mm/2])
      difference() {
        cylinder(h=pcb_spacer_height_mm, r=shaft_diameter_mm/2 + pcb_spacer_wall_mm, center=true);
        cylinder(h=pcb_spacer_height_mm + overlap_mm*2, r=shaft_diameter_mm/2 + overlap_mm/4, center=true);
      }
  }
}

// Buzzer
module buzzer() {
  color("Black") {
    translate([head_diameter_mm/2 + sprue_length_mm + (shaft_diameter_mm/2 + pcb_spacer_wall_mm) + (buzzer_diameter_mm/2) - overlap_mm, 0, -head_height_mm/2 - buzzer_height_mm/2])
      cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true);
  }
}

// Pin Socket
module pin_socket() {
  color("Blue") {
    translate([head_diameter_mm/2 + sprue_length_mm + (shaft_diameter_mm/2 + pcb_spacer_wall_mm) + buzzer_diameter_mm + pin_socket_width_mm/2 - overlap_mm, 0, -head_height_mm/2 - pin_socket_height_mm/2])
      cube([pin_socket_width_mm, pin_socket_depth_mm, pin_socket_height_mm], center=true);
  }
}

// Assembly
module assembly() {
  screw_and_washer();
  pcb_spacer();
  buzzer();
  pin_socket();
}

assembly();