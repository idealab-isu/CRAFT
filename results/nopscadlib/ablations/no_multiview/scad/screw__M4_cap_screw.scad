// Parameters
thread_nominal_diameter_mm = 4; //[2:8:0.1]
length_under_head_mm = 10; //[5:20:0.5]
head_diameter_mm = 7; //[3.5:14:0.1]
head_height_mm = 4; //[2:8:0.1]
thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
thread_length_mm = 10; //[5:20:0.5]
shank_diameter_mm = 4; //[2:8:0.1]
socket_af_mm = 3; //[2:6:0.1]
socket_depth_mm = 2.5; //[1.5:5:0.1]
under_head_chamfer_height_mm = 0.6; //[0.3:1.2:0.05]
thread_runout_length_mm = 1.2; //[0.6:2.4:0.1]
overlap_mm = 0.8; //[0.2:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Pin Socket - Custom detailed geometry
module pin_socket() {
  color("Silver") {
    // Simple representation of a pin socket
    cylinder(d=2, h=5, center=true, $fn=32);
  }
}

// Screw And Washer - Custom detailed geometry
module screw_and_washer() {
  color("DimGray") {
    // Simple representation of a screw with washer
    union() {
      cylinder(d=shank_diameter_mm, h=2, center=true, $fn=32);
      translate([0, 0, -1]) cylinder(d=shank_diameter_mm + 2, h=1, center=true, $fn=32);
    }
  }
}

// PCB Spacer - Custom detailed geometry
module pcb_spacer() {
  color("Black") {
    // Simple representation of a PCB spacer
    cylinder(d=5, h=10, center=true, $fn=32);
  }
}

// Buzzer - Custom detailed geometry
module buzzer() {
  color("Copper") {
    // Simple representation of a buzzer
    cylinder(d=10, h=5, center=true, $fn=32);
  }
}

// Main Screw with Hex Socket
module screw_with_hex_socket() {
  difference() {
    union() {
      // Cap Head
      translate([0, 0, 0])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=64);
      
      // Threaded Shaft
      translate([0, 0, -head_height_mm/2 - length_under_head_mm/2 + overlap_mm])
        cylinder(r=shank_diameter_mm/2, h=length_under_head_mm, center=true, $fn=64);
      
      // Under Head Transition Fillet or Chamfer
      translate([0, 0, -head_height_mm/2 - under_head_chamfer_height_mm/2 + overlap_mm])
        cylinder(r1=head_diameter_mm/2, r2=shank_diameter_mm/2, h=under_head_chamfer_height_mm, center=true, $fn=64);
      
      // Thread Runout
      translate([0, 0, -head_height_mm/2 - under_head_chamfer_height_mm - thread_runout_length_mm/2 + overlap_mm])
        cylinder(r1=shank_diameter_mm/2, r2=shank_diameter_mm/2 - thread_pitch_mm*0.25, h=thread_runout_length_mm, center=true, $fn=64);
      
      // Pin Socket
      pin_socket();
      
      // Screw And Washer
      screw_and_washer();
      
      // PCB Spacer
      pcb_spacer();
      
      // Buzzer
      buzzer();
    }
    
    // Hex Socket Recess
    translate([0, 0, head_height_mm/2 - (socket_depth_mm + eps_mm)/2])
      cylinder(r=socket_af_mm/(2*cos(30)), h=socket_depth_mm + eps_mm, center=true, $fn=6);
  }
}

// Assembly
module assembly() {
  screw_with_hex_socket();
}

assembly();