// Parameters
shaft_diameter_mm = 5; //[2.5:10:0.1]
overall_length_mm = 10; //[5:20:0.5]
head_diameter_mm = 8.5; //[4.25:17:0.1]
head_height_mm = 5; //[2.5:10:0.1]
socket_af_mm = 4; //[2:8:0.1]
socket_depth_mm = 3; //[1.5:6:0.1]
thread_minor_diameter_mm = 4.2; //[2.1:8.4:0.1]
unthreaded_length_mm = 2; //[0:6:0.5]
runout_length_mm = 1; //[0.5:3:0.1]
head_shank_chamfer_height_mm = 0.8; //[0.3:2:0.1]
overlap_mm = 1; //[0.5:2:0.1]
washer_outer_diameter_mm = 10; //[5:20:0.5]
washer_thickness_mm = 1; //[0.5:3:0.1]
washer_hole_diameter_mm = 5.5; //[3:11:0.1]
pcb_spacer_height_mm = 6; //[3:12:0.5]
pcb_spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
pcb_spacer_clearance_diameter_mm = 5.6; //[3:11:0.1]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 6; //[3:12:0.5]
pin_socket_width_mm = 8; //[4:16:0.5]
pin_socket_depth_mm = 4; //[2:8:0.5]
pin_socket_height_mm = 6; //[3:12:0.5]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(r=pcb_spacer_clearance_diameter_mm/2 + pcb_spacer_wall_mm, h=pcb_spacer_height_mm, center=true);
      translate([0, 0, -overlap_mm])
        cylinder(r=pcb_spacer_clearance_diameter_mm/2, h=pcb_spacer_height_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Threaded shaft
      translate([0, 0, -overall_length_mm/2])
        cylinder(r=shaft_diameter_mm/2, h=overall_length_mm, center=true);
      // Unthreaded shank
      translate([0, 0, -unthreaded_length_mm/2])
        cylinder(r=shaft_diameter_mm/2, h=unthreaded_length_mm, center=true);
      // Runout cone
      translate([0, 0, -unthreaded_length_mm - runout_length_mm/2])
        cylinder(r1=shaft_diameter_mm/2, r2=thread_minor_diameter_mm/2, h=runout_length_mm, center=true);
      // Socket cap head
      translate([0, 0, head_height_mm/2 - overlap_mm])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);
      // Head to shank chamfer
      translate([0, 0, head_shank_chamfer_height_mm/2 - overlap_mm])
        cylinder(r1=head_diameter_mm/2, r2=shaft_diameter_mm/2, h=head_shank_chamfer_height_mm, center=true);
      // Hex socket recess
      translate([0, 0, head_height_mm - socket_depth_mm/2 - overlap_mm])
        cylinder(r=socket_af_mm/(2*cos(30)), h=socket_depth_mm, center=true);
    }
  }
  // Washer
  color("Silver") {
    difference() {
      translate([0, 0, head_height_mm + washer_thickness_mm/2 - overlap_mm])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
      translate([0, 0, head_height_mm + washer_thickness_mm/2 - overlap_mm])
        cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([0, 0, head_height_mm + washer_thickness_mm + pcb_spacer_height_mm + buzzer_height_mm/2 - overlap_mm])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
  }
}

// Pin Socket - complete geometry
module pin_socket() {
  color([0.2, 0.2, 0.2]) {
    translate([buzzer_diameter_mm/2 + pin_socket_width_mm/2 - overlap_mm, 0, head_height_mm + washer_thickness_mm + pcb_spacer_height_mm + buzzer_height_mm - pin_socket_height_mm/2 - overlap_mm])
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