// Parameters
thread_major_diameter_mm = 3; //[1.5:6:0.1]
overall_length_mm = 10; //[5:20:0.5]
head_diameter_mm = 5.5; //[2.75:11:0.1]
head_height_mm = 3; //[1.5:6:0.1]
thread_pitch_mm = 0.5; //[0.25:1:0.05]
thread_length_mm = 10; //[5:20:0.5]
socket_across_flats_mm = 2.5; //[1.25:5:0.05]
socket_depth_mm = 1.5; //[0.75:3:0.05]
chamfer_under_head_mm = 0.6; //[0.3:1.2:0.05]
thread_minor_diameter_mm = 2.6; //[1.3:5.2:0.1]
thread_ridge_height_mm = 0.2; //[0.1:0.4:0.05]
thread_ridge_width_mm = 0.25; //[0.1:0.6:0.05]
thread_ridge_count = 12; //[6:30:1]
washer_outer_diameter_mm = 7; //[3.5:14:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]
washer_hole_diameter_mm = 3.4; //[1.7:6.8:0.1]
pcb_spacer_outer_diameter_mm = 6; //[3:12:0.1]
pcb_spacer_height_mm = 5; //[2.5:10:0.5]
pcb_spacer_hole_diameter_mm = 3.4; //[1.7:6.8:0.1]
pin_socket_body_length_mm = 6; //[3:12:0.5]
pin_socket_body_width_mm = 3; //[1.5:6:0.5]
pin_socket_body_height_mm = 4; //[2:8:0.5]
buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 7; //[3.5:14:0.5]
assembly_overlap_mm = 1; //[0.5:2:0.1]

// Pin Socket - Detailed Geometry
module pin_socket() {
  color("DimGray")
    cube([pin_socket_body_length_mm, pin_socket_body_width_mm, pin_socket_body_height_mm], center=true);
}

// Screw and Washer - Detailed Geometry
module screw_and_washer() {
  color("Silver") {
    // Cap Head
    translate([0, 0, head_height_mm/2])
      cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true, $fn=32);

    // Hex Socket Recess (visual only; not subtracted)
    translate([0, 0, head_height_mm - socket_depth_mm/2])
      cylinder(r=(socket_across_flats_mm/2)/cos(30), h=socket_depth_mm, center=true, $fn=6);

    // Under Head Chamfer (overlaps head + shaft slightly)
    translate([0, 0, chamfer_under_head_mm/2 - assembly_overlap_mm/2])
      cylinder(r1=head_diameter_mm/2, r2=thread_major_diameter_mm/2, h=chamfer_under_head_mm, center=true, $fn=32);

    // Screw Body (major diameter)
    translate([0, 0, -overall_length_mm/2])
      cylinder(r=thread_major_diameter_mm/2, h=overall_length_mm, center=true, $fn=32);

    // Threaded Shaft Core (minor diameter)
    translate([0, 0, -thread_length_mm/2])
      cylinder(r=thread_minor_diameter_mm/2, h=thread_length_mm, center=true, $fn=32);

    // Thread Ridges
    for (i = [0:thread_ridge_count-1]) {
      translate([0, 0,
        -thread_length_mm/2
        + thread_ridge_width_mm/2
        + i*(thread_length_mm-thread_ridge_width_mm)/(thread_ridge_count-1)
      ])
        cylinder(r=thread_minor_diameter_mm/2 + thread_ridge_height_mm,
                 h=thread_ridge_width_mm, center=true, $fn=32);
    }

    // Washer (kept overlapping head slightly for guaranteed union)
    difference() {
      translate([0, 0, head_height_mm + washer_thickness_mm/2 - assembly_overlap_mm])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true, $fn=32);
      translate([0, 0, head_height_mm + washer_thickness_mm/2 - assembly_overlap_mm])
        cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*assembly_overlap_mm, center=true, $fn=32);
    }
  }
}

// PCB Spacer - Detailed Geometry
module pcb_spacer() {
  color("Silver") {
    difference() {
      translate([0, 0, head_height_mm + washer_thickness_mm - 2*assembly_overlap_mm + pcb_spacer_height_mm/2])
        cylinder(r=pcb_spacer_outer_diameter_mm/2, h=pcb_spacer_height_mm, center=true, $fn=32);
      translate([0, 0, head_height_mm + washer_thickness_mm - 2*assembly_overlap_mm + pcb_spacer_height_mm/2])
        cylinder(r=pcb_spacer_hole_diameter_mm/2, h=pcb_spacer_height_mm + 2*assembly_overlap_mm, center=true, $fn=32);
    }
  }
}

// Buzzer - Detailed Geometry
module buzzer() {
  color("Black")
    cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true, $fn=32);
}

// NEW: Connecting arm to guarantee physical attachment between pin socket and buzzer
module connecting_arm(arm_len, arm_w, arm_h) {
  color("DimGray")
    cube([arm_len, arm_w, arm_h], center=true);
}

// Assembly (ALL parts unioned and physically connected with overlap)
module assembly() {
  // Z placement (kept as in original intent)
  z_pin = head_height_mm + washer_thickness_mm - 2*assembly_overlap_mm + pcb_spacer_height_mm - pin_socket_body_height_mm/2;
  z_buz = head_height_mm + washer_thickness_mm - 2*assembly_overlap_mm + pcb_spacer_height_mm - buzzer_height_mm/2;

  // X placement: pin socket near spacer
  x_pin = pcb_spacer_outer_diameter_mm/2 + pin_socket_body_length_mm/2 - assembly_overlap_mm;

  // Force buzzer to overlap the pin socket by assembly_overlap_mm (no gap)
  // Condition: (x_buz - buzzer_r) = (x_pin + pin_L/2) - overlap
  x_buz = x_pin + pin_socket_body_length_mm/2 + buzzer_diameter_mm/2 - assembly_overlap_mm;

  // Add a connecting arm that overlaps BOTH the pin socket and the buzzer by assembly_overlap_mm
  // Left face of arm:  x_pin + pin_L/2 - overlap
  // Right face of arm: x_buz - buzzer_r + overlap
  x_arm_left  = x_pin + pin_socket_body_length_mm/2 - assembly_overlap_mm;
  x_arm_right = x_buz - buzzer_diameter_mm/2 + assembly_overlap_mm;

  arm_len = max(0.01, x_arm_right - x_arm_left);
  x_arm = (x_arm_left + x_arm_right)/2;

  // Match pin socket cross-section so it visually "continues" and guarantees contact
  arm_w = pin_socket_body_width_mm;
  arm_h = pin_socket_body_height_mm;
  z_arm = z_pin; // align with pin socket center for solid connection

  union() {
    screw_and_washer();
    pcb_spacer();

    translate([x_pin, 0, z_pin])
      pin_socket();

    // Connecting arm ensures buzzer is physically attached (fixes floating/gap)
    translate([x_arm, 0, z_arm])
      connecting_arm(arm_len, arm_w, arm_h);

    // Buzzer attached (overlaps pin socket and arm by assembly_overlap_mm)
    translate([x_buz, 0, z_buz])
      buzzer();
  }
}

assembly();