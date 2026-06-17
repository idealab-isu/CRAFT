// Parameters
shank_diameter_mm = 3; //[1.5:6:0.1]
length_under_head_mm = 10; //[5:20:0.5]
head_diameter_mm = 5.5; //[3:11:0.1]
head_height_mm = 2; //[1:4:0.1]
socket_across_flats_mm = 2.5; //[1.5:4:0.1]
socket_depth_mm = 1.5; //[0.8:2.5:0.1]
thread_coverage_ratio = 1; //[0.3:1:0.05]
thread_major_diameter_mm = 3; //[1.5:6:0.1]
thread_minor_diameter_mm = 2.7; //[1.2:5.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
washer_outer_diameter_mm = 7; //[4:14:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]
pcb_spacer_outer_diameter_mm = 6; //[3:12:0.1]
pcb_spacer_height_mm = 4; //[2:10:0.5]
pin_socket_body_length_mm = 6; //[3:15:0.5]
pin_socket_body_width_mm = 3; //[2:8:0.5]
pin_socket_body_height_mm = 4; //[2:10:0.5]
buzzer_radius_mm = 6; //[3:15:0.5]
buzzer_height_mm = 5; //[2:12:0.5]

// Derived Z reference planes (Z+ up)
// Put the underside of the head at Z=0 so everything stacks downward.
z_head_bottom = 0;
z_head_top    = z_head_bottom + head_height_mm;

// Washer sits directly under head with slight overlap into head
z_washer_top    = z_head_bottom + overlap_mm;
z_washer_bottom = z_washer_top - washer_thickness_mm;

// Shank starts under head and runs down; overlap into head to guarantee connection
z_shank_top    = z_head_bottom + overlap_mm;
z_shank_bottom = z_shank_top - length_under_head_mm;

// PCB spacer under washer with overlap
z_spacer_top    = z_washer_bottom + overlap_mm;
z_spacer_bottom = z_spacer_top - pcb_spacer_height_mm;

// Pin socket under spacer with overlap
z_pin_top    = z_spacer_bottom + overlap_mm;
z_pin_bottom = z_pin_top - pin_socket_body_height_mm;

// Buzzer under pin socket with overlap
z_buzzer_top    = z_pin_bottom + overlap_mm;
z_buzzer_bottom = z_buzzer_top - buzzer_height_mm;

// Screw and Washer - connected geometry
module screw_and_washer() {
  color("DimGray")
  union() {
    // Cap head with hex socket cut
    difference() {
      translate([0, 0, (z_head_bottom + z_head_top)/2])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=64);

      // Hex socket: referenced from head top, cut downward
      translate([0, 0, z_head_top - socket_depth_mm/2])
        cylinder(r=(socket_across_flats_mm/cos(30))/2, h=socket_depth_mm, center=true, $fn=6);
    }

    // Washer (ring) directly under head, overlapping into head by overlap_mm
    translate([0, 0, (z_washer_bottom + z_washer_top)/2])
      difference() {
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=64);
        // Slightly larger hole to avoid coincident faces; does not affect connectivity
        cylinder(r=shank_diameter_mm/2 + 0.05, h=washer_thickness_mm + 0.2, center=true, $fn=64);
      }

    // Shank (single continuous cylinder; thread section is represented by same major diameter)
    translate([0, 0, (z_shank_bottom + z_shank_top)/2])
      cylinder(r=shank_diameter_mm/2, h=length_under_head_mm, center=true, $fn=64);

    // Optional "threaded section" visual (same axis) — overlap ensured by same placement
    // Kept for design parity; it is fully coincident/overlapping with shank so it cannot float.
    translate([0, 0, (z_shank_bottom + z_shank_top)/2])
      cylinder(r=thread_major_diameter_mm/2, h=length_under_head_mm*thread_coverage_ratio, center=true, $fn=64);
  }
}

// PCB Spacer - connected to washer via overlap
module pcb_spacer() {
  color("Silver")
  translate([0, 0, (z_spacer_bottom + z_spacer_top)/2])
    difference() {
      cylinder(r=pcb_spacer_outer_diameter_mm/2, h=pcb_spacer_height_mm, center=true, $fn=64);
      cylinder(r=shank_diameter_mm/2 + 0.05, h=pcb_spacer_height_mm + 0.2, center=true, $fn=64);
    }
}

// Pin Socket - connected to spacer via overlap
module pin_socket() {
  color("Black")
  translate([0, 0, (z_pin_bottom + z_pin_top)/2])
    cube([pin_socket_body_length_mm, pin_socket_body_width_mm, pin_socket_body_height_mm], center=true);
}

// Buzzer - connected to pin socket via overlap
module buzzer() {
  color("DarkSlateGray")
  translate([0, 0, (z_buzzer_bottom + z_buzzer_top)/2])
    cylinder(r=buzzer_radius_mm, h=buzzer_height_mm, center=true, $fn=64);
}

// Assembly: single connected solid (union) with all overlaps enforced
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    pin_socket();
    buzzer();
  }
}

assembly();