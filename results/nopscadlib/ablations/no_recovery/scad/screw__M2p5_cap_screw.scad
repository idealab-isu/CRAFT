// Parameters
shank_diameter_mm = 2.5; //[1.25:5:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 4.5; //[2.25:9:0.1]
head_height_mm = 2.5; //[1.25:5:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]
threaded = 1; //[0:1:1]
thread_pitch_mm = 0.45; //[0.25:1:0.05]
thread_depth_mm = 0.15; //[0.05:0.4:0.01]
thread_length_mm = 7; //[3.5:14:0.5]
socket_across_flats_mm = 2; //[1:4:0.1]
socket_depth_mm = 1.5; //[0.75:3:0.1]
washer_outer_diameter_mm = 6; //[3:12:0.1]
washer_thickness_mm = 0.8; //[0.4:1.6:0.1]
washer_hole_diameter_mm = 2.8; //[1.4:5.6:0.1]
pcb_spacer_height_mm = 6; //[3:12:0.5]
pcb_spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
pcb_spacer_clearance_diameter_mm = 2.9; //[1.5:6:0.1]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 6; //[3:12:0.5]
pin_socket_width_mm = 8; //[4:16:0.5]
pin_socket_depth_mm = 5; //[2.5:10:0.5]
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
      // Screw Shank
      translate([0, 0, -head_height_mm/2])
        cylinder(r=shank_diameter_mm/2, h=length_mm - head_height_mm, center=true);
      // Cap Head
      translate([0, 0, length_mm/2 - head_height_mm/2])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);
      // Hex Socket Recess
      translate([0, 0, length_mm/2 - socket_depth_mm/2 + overlap_mm])
        difference() {
          cylinder(r=(socket_across_flats_mm/2)/cos(30), h=socket_depth_mm, center=true);
        }
      // Thread Representation
      if (threaded) {
        translate([0, 0, -length_mm/2 + head_height_mm + thread_length_mm/2])
          cylinder(r=shank_diameter_mm/2 + thread_depth_mm, h=thread_length_mm, center=true);
      }
      // Washer
      translate([0, 0, length_mm/2 - head_height_mm - washer_thickness_mm/2 + overlap_mm])
        difference() {
          cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
          translate([0, 0, -overlap_mm])
            cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
        }
    }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color([0.1, 0.1, 0.6]) {
    translate([head_diameter_mm/2 + buzzer_diameter_mm/2 - overlap_mm, 0, -length_mm/2 - pcb_spacer_height_mm + buzzer_height_mm/2 - overlap_mm])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
  }
}

// Pin Socket - complete geometry
module pin_socket() {
  color([0.2, 0.2, 0.2]) {
    translate([head_diameter_mm/2 + buzzer_diameter_mm + pin_socket_width_mm/2 - 2*overlap_mm, 0, -length_mm/2 - pcb_spacer_height_mm + pin_socket_height_mm/2 - overlap_mm])
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