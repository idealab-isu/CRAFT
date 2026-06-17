// Parameters
shank_diameter_mm = 4; //[2:8:0.1]
length_under_head_mm = 10; //[5:20:0.5]
head_diameter_mm = 7; //[3.5:14:0.1]
head_height_mm = 4; //[2:8:0.1]
hex_socket_af_mm = 3; //[1.5:6:0.1]
hex_socket_depth_mm = 2.5; //[1:4:0.1]
thread_representation_diameter_factor = 0.98; //[0.9:1:0.01]
washer_outer_diameter_mm = 9; //[4.5:18:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]
pcb_spacer_height_mm = 6; //[3:12:0.5]
pcb_spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
screw_clearance_diameter_mm = 4.5; //[4.1:5.5:0.1]
buzzer_body_diameter_mm = 12; //[6:24:0.5]
buzzer_body_height_mm = 7; //[3.5:14:0.5]
pin_socket_body_width_mm = 10; //[5:20:0.5]
pin_socket_body_depth_mm = 5; //[2.5:10:0.5]
pin_socket_body_height_mm = 6; //[3:12:0.5]
pin_socket_pin_diameter_mm = 1; //[0.5:2:0.1]
pin_socket_pin_length_mm = 4; //[2:8:0.5]
pin_socket_pin_spacing_mm = 2.54; //[2:5.08:0.01]
overlap_mm = 1; //[0.5:2:0.1]

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      cylinder(r=screw_clearance_diameter_mm/2 + pcb_spacer_wall_mm, h=pcb_spacer_height_mm, center=true);
      translate([0, 0, -overlap_mm])
        cylinder(r=screw_clearance_diameter_mm/2, h=pcb_spacer_height_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    union() {
      // Screw
      difference() {
        union() {
          translate([0, 0, -length_under_head_mm/2])
            cylinder(r=shank_diameter_mm*thread_representation_diameter_factor/2, h=length_under_head_mm, center=true);
          translate([0, 0, head_height_mm/2 - overlap_mm])
            cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);
        }
        translate([0, 0, head_height_mm - hex_socket_depth_mm/2 - overlap_mm])
          cylinder(r=hex_socket_af_mm/(2*cos(30)), h=hex_socket_depth_mm, center=true);
      }
      // Washer
      difference() {
        translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
        translate([0, 0, -washer_thickness_mm/2 + overlap_mm])
          cylinder(r=screw_clearance_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([washer_outer_diameter_mm/2 + buzzer_body_diameter_mm/2 - overlap_mm, 0, -washer_thickness_mm/2 + overlap_mm])
      cylinder(r=buzzer_body_diameter_mm/2, h=buzzer_body_height_mm, center=true);
  }
}

// Pin Socket - complete geometry
module pin_socket() {
  color("Blue") {
    union() {
      // Body
      translate([washer_outer_diameter_mm/2 + buzzer_body_diameter_mm + pin_socket_body_width_mm/2 - 2*overlap_mm, 0, -washer_thickness_mm/2 + overlap_mm])
        cube([pin_socket_body_width_mm, pin_socket_body_depth_mm, pin_socket_body_height_mm], center=true);
      // Pins
      translate([washer_outer_diameter_mm/2 + buzzer_body_diameter_mm + pin_socket_body_width_mm/2 - 2*overlap_mm, -pin_socket_pin_spacing_mm/2, -washer_thickness_mm/2 - pin_socket_body_height_mm/2 - pin_socket_pin_length_mm/2 + 2*overlap_mm])
        cylinder(r=pin_socket_pin_diameter_mm/2, h=pin_socket_pin_length_mm, center=true);
      translate([washer_outer_diameter_mm/2 + buzzer_body_diameter_mm + pin_socket_body_width_mm/2 - 2*overlap_mm, pin_socket_pin_spacing_mm/2, -washer_thickness_mm/2 - pin_socket_body_height_mm/2 - pin_socket_pin_length_mm/2 + 2*overlap_mm])
        cylinder(r=pin_socket_pin_diameter_mm/2, h=pin_socket_pin_length_mm, center=true);
    }
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