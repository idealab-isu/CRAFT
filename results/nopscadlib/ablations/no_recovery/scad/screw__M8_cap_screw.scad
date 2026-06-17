// Parameters
nominal_diameter_mm = 8; //[4:16:0.1]
under_head_length_mm = 10; //[5:20:0.5]
head_diameter_mm = 13; //[8:26:0.1]
head_height_mm = 8; //[4:16:0.1]
thread_pitch_mm = 1.25; //[0.5:2.5:0.05]
thread_length_mm = 10; //[5:20:0.5]
socket_across_flats_mm = 6; //[3:12:0.1]
socket_depth_mm = 4; //[2:8:0.1]
overlap_mm = 1; //[0.5:2:0.1]
under_head_fillet_radius_mm = 0.8; //[0.3:2:0.1]
thread_minor_diameter_factor = 0.85; //[0.75:0.95:0.01]
washer_outer_diameter_mm = 16; //[10:32:0.5]
washer_thickness_mm = 1.6; //[0.8:3.2:0.1]
washer_hole_diameter_mm = 8.5; //[6.5:12:0.1]
pcb_spacer_height_mm = 6; //[3:15:0.5]
pcb_spacer_wall_mm = 1.8; //[1:3.6:0.1]
pcb_spacer_clearance_diameter_mm = 8.6; //[8.2:10:0.1]
buzzer_diameter_mm = 12; //[8:24:0.5]
buzzer_height_mm = 7; //[4:14:0.5]
pin_socket_width_mm = 10; //[6:20:0.5]
pin_socket_depth_mm = 5; //[3:12:0.5]
pin_socket_height_mm = 8; //[4:16:0.5]

// Screw and Washer - complete geometry
module screw_and_washer() {
  color("DimGray") {
    // Cap Head
    translate([0, 0, under_head_length_mm + head_height_mm / 2])
      cylinder(r=head_diameter_mm / 2, h=head_height_mm, center=true, $fn=64);
    
    // Screw Shaft
    translate([0, 0, under_head_length_mm / 2])
      cylinder(r=nominal_diameter_mm / 2, h=under_head_length_mm, center=true, $fn=64);
    
    // Threaded Section
    translate([0, 0, thread_length_mm / 2])
      cylinder(r=(nominal_diameter_mm * thread_minor_diameter_factor) / 2, h=thread_length_mm, center=true, $fn=64);
    
    // Under Head Fillet
    translate([0, 0, under_head_length_mm - under_head_fillet_radius_mm])
      rotate_extrude($fn=64) translate([nominal_diameter_mm / 2 + under_head_fillet_radius_mm, 0])
      circle(r=under_head_fillet_radius_mm);
    
    // Hex Socket
    translate([0, 0, under_head_length_mm + head_height_mm - socket_depth_mm / 2])
      difference() {
        cylinder(r=socket_across_flats_mm / (2 * cos(30)), h=socket_depth_mm + overlap_mm, center=true, $fn=6);
      }
    
    // Washer
    translate([0, 0, under_head_length_mm + head_height_mm + washer_thickness_mm / 2 - overlap_mm])
      difference() {
        cylinder(r=washer_outer_diameter_mm / 2, h=washer_thickness_mm, center=true, $fn=64);
        translate([0, 0, -overlap_mm])
          cylinder(r=washer_hole_diameter_mm / 2, h=washer_thickness_mm + 2 * overlap_mm, center=true, $fn=64);
      }
  }
}

// PCB Spacer - complete geometry
module pcb_spacer() {
  color("Silver") {
    translate([0, 0, under_head_length_mm + head_height_mm + washer_thickness_mm + pcb_spacer_height_mm / 2 - overlap_mm])
      difference() {
        cylinder(r=pcb_spacer_clearance_diameter_mm / 2 + pcb_spacer_wall_mm, h=pcb_spacer_height_mm, center=true, $fn=64);
        translate([0, 0, -overlap_mm])
          cylinder(r=pcb_spacer_clearance_diameter_mm / 2, h=pcb_spacer_height_mm + 2 * overlap_mm, center=true, $fn=64);
      }
  }
}

// Buzzer - complete geometry
module buzzer() {
  color("Black") {
    translate([0, 0, under_head_length_mm + head_height_mm + washer_thickness_mm + pcb_spacer_height_mm + buzzer_height_mm / 2 - overlap_mm])
      cylinder(r=buzzer_diameter_mm / 2, h=buzzer_height_mm, center=true, $fn=64);
  }
}

// Pin Socket - complete geometry
module pin_socket() {
  color("Blue") {
    translate([0, 0, under_head_length_mm + head_height_mm + washer_thickness_mm + pcb_spacer_height_mm + buzzer_height_mm + pin_socket_height_mm / 2 - overlap_mm])
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