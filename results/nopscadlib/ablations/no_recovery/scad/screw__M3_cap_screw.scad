// Parameters
thread_diameter_mm = 3; //[1.5:6:0.1]
length_under_head_mm = 10; //[5:20:0.5]
head_diameter_mm = 5.5; //[3:11:0.1]
head_height_mm = 3; //[1.5:6:0.1]
hex_socket_af_mm = 2.5; //[1.5:4:0.1]
hex_socket_depth_mm = 1.6; //[0.8:3:0.1]
tip_cone_height_mm = 1; //[0.5:2:0.1]
overlap_mm = 0.8; //[0.2:2:0.1]
spacer_height_mm = 6; //[3:12:0.5]
spacer_wall_mm = 1.8; //[0.8:3.6:0.1]
washer_outer_diameter_mm = 7; //[4:14:0.1]
washer_thickness_mm = 0.8; //[0.4:1.6:0.1]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 5; //[2.5:10:0.5]
pin_socket_width_mm = 6; //[3:12:0.5]
pin_socket_depth_mm = 3; //[1.5:6:0.5]
pin_socket_height_mm = 4; //[2:8:0.5]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      cylinder(r=thread_diameter_mm/2 + spacer_wall_mm, h=spacer_height_mm, center=true);
      translate([0, 0, -overlap_mm])
        cylinder(r=thread_diameter_mm/2 + (overlap_mm/4), h=spacer_height_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw shaft
      translate([0, 0, -length_under_head_mm/2])
        cylinder(r=thread_diameter_mm/2, h=length_under_head_mm, center=true);
      // Tip
      translate([0, 0, -length_under_head_mm - tip_cone_height_mm/2 + overlap_mm])
        cylinder(r1=thread_diameter_mm/2, r2=0, h=tip_cone_height_mm, center=true);
      // Head
      translate([0, 0, head_height_mm/2 - overlap_mm])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);
      // Hex socket
      translate([0, 0, head_height_mm - hex_socket_depth_mm/2 - overlap_mm])
        difference() {
          cylinder(r=(hex_socket_af_mm/cos(30))/2, h=hex_socket_depth_mm, center=true);
        }
      // Washer
      translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
        difference() {
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
          translate([0, 0, -overlap_mm])
            cylinder(r=thread_diameter_mm/2 + (overlap_mm/4), h=washer_thickness_mm + 2*overlap_mm, center=true);
        }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([0, 0, -length_under_head_mm - tip_cone_height_mm - spacer_height_mm - buzzer_height_mm/2 + overlap_mm])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
  }
}

// Pin Socket - complete geometry
module pin_socket() {
  color("Blue") {
    translate([buzzer_diameter_mm/2 + pin_socket_width_mm/2 - overlap_mm, 0, -length_under_head_mm - tip_cone_height_mm - spacer_height_mm - buzzer_height_mm/2 + overlap_mm])
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