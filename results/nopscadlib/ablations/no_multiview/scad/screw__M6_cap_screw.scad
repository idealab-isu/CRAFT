// Parameters
shaft_diameter_mm = 6; //[3:12:0.1]
length_under_head_mm = 10; //[5:20:0.5]
head_diameter_mm = 10; //[6:20:0.1]
head_height_mm = 6; //[3:12:0.1]
socket_across_flats_mm = 5; //[3:8:0.1]
socket_depth_mm = 4; //[2:6:0.1]
threaded = 1; //[0:1:1]
thread_pitch_mm = 1; //[0.5:2:0.1]
thread_depth_mm = 0.3; //[0.1:0.8:0.05]
under_head_fillet_height_mm = 1.2; //[0.6:2.4:0.1]
overlap_mm = 0.8; //[0.2:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
placeholder_size_mm = 0.01; //[0.001:0.1:0.001]

// Pin Socket - Detailed Geometry
module pin_socket() {
  color("Silver") {
    // Placeholder for pin socket geometry
    translate([0, 0, -length_under_head_mm + placeholder_size_mm/2])
      cube([placeholder_size_mm, placeholder_size_mm, placeholder_size_mm], center=true);
  }
}

// Screw And Washer - Detailed Geometry
module screw_and_washer() {
  color("DimGray") {
    // Placeholder for screw and washer geometry
    translate([0, 0, head_height_mm - placeholder_size_mm/2])
      cube([placeholder_size_mm, placeholder_size_mm, placeholder_size_mm], center=true);
  }
}

// PCB Spacer - Detailed Geometry
module pcb_spacer() {
  color("Black") {
    // Placeholder for PCB spacer geometry
    translate([0, 0, -length_under_head_mm/2])
      cube([placeholder_size_mm, placeholder_size_mm, placeholder_size_mm], center=true);
  }
}

// Buzzer - Detailed Geometry
module buzzer() {
  color("Copper") {
    // Placeholder for buzzer geometry
    translate([0, 0, head_height_mm/2])
      cube([placeholder_size_mm, placeholder_size_mm, placeholder_size_mm], center=true);
  }
}

// Screw with Thread and Socket
module screw_with_thread_and_socket() {
  color("Steel") {
    // Cap Head
    translate([0, 0, head_height_mm/2])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);

    // Shaft
    translate([0, 0, -length_under_head_mm/2])
      cylinder(h=length_under_head_mm, r=shaft_diameter_mm/2, center=true);

    // Under Head Fillet or Chamfer
    translate([0, 0, -under_head_fillet_height_mm/2 + overlap_mm/2])
      cylinder(h=under_head_fillet_height_mm, r1=head_diameter_mm/2, r2=shaft_diameter_mm/2, center=true);

    // Hex Socket Recess
    translate([0, 0, head_height_mm - socket_depth_mm/2])
      rotate([0, 0, 0])
      cylinder(h=socket_depth_mm + eps_mm, r=socket_across_flats_mm/(2*cos(30)), center=true);

    // Thread Representation
    if (threaded) {
      difference() {
        translate([0, 0, -length_under_head_mm/2])
          cylinder(h=length_under_head_mm, r=shaft_diameter_mm/2, center=true);
        translate([0, 0, -length_under_head_mm/2])
          cylinder(h=length_under_head_mm, r=shaft_diameter_mm/2 - thread_depth_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  screw_with_thread_and_socket();
  pin_socket();
  screw_and_washer();
  pcb_spacer();
  buzzer();
}

assembly();