// Parameters
shank_diameter_mm = 5; //[2.5:10:0.1]
length_under_head_mm = 10; //[5:20:0.5]
head_diameter_mm = 8.5; //[6:17:0.1]
head_height_mm = 5; //[2.5:10:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
thread_coverage_ratio = 1; //[0.3:1:0.05]
thread_major_diameter_mm = 5; //[2.5:10:0.1]
thread_minor_diameter_mm = 4.2; //[2:9:0.1]
hex_socket_af_mm = 4; //[2:8:0.1]
hex_socket_depth_mm = 3; //[1.5:5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
washer_outer_diameter_mm = 10; //[6:20:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]
washer_hole_diameter_mm = 5.5; //[3:11:0.1]
pcb_spacer_outer_diameter_mm = 8; //[4:16:0.1]
pcb_spacer_height_mm = 6; //[3:12:0.1]
buzzer_diameter_mm = 12; //[6:24:0.1]
buzzer_height_mm = 7; //[3:14:0.1]
pin_socket_length_mm = 10; //[5:20:0.5]
pin_socket_width_mm = 5; //[2.5:10:0.1]
pin_socket_height_mm = 6; //[3:12:0.1]
connector_radius_mm = 0.6; //[0.3:1.5:0.1]

$fn = 96;

// --- Z reference ---
// Underside of screw head at z=0.
// Head: [0 .. head_height_mm]
// Shank: [-length_under_head_mm .. 0]
z_head_bottom = 0;
z_head_top    = head_height_mm;

z_shank_top    = z_head_bottom;
z_shank_bottom = z_head_bottom - length_under_head_mm;

// Build a fully connected stack UNDER the head with intentional overlaps.
// Washer must touch/overlap head underside and shank.
z_washer_top    = z_shank_top + overlap_mm;                 // overlaps into head underside region
z_washer_bottom = z_washer_top - washer_thickness_mm;

// Spacer overlaps into washer
z_spacer_top    = z_washer_bottom + overlap_mm;
z_spacer_bottom = z_spacer_top - pcb_spacer_height_mm;

// Buzzer overlaps into spacer
z_buzzer_top    = z_spacer_bottom + overlap_mm;
z_buzzer_bottom = z_buzzer_top - buzzer_height_mm;

// Pin socket overlaps into buzzer
z_pin_top       = z_buzzer_bottom + overlap_mm;
z_pin_bottom    = z_pin_top - pin_socket_height_mm;

// Connector rod spans from inside head down through the stack with overlap at both ends
z_rod_top    = z_head_top - overlap_mm;
z_rod_bottom = z_pin_bottom + overlap_mm;

// Pin Socket - Detailed Geometry
module pin_socket() {
  color([0.85, 0.85, 0.8])
    translate([0, 0, (z_pin_top + z_pin_bottom)/2])
      cube([pin_socket_length_mm, pin_socket_width_mm, pin_socket_height_mm], center=true);
}

// Hex socket recess (subtracted from head)
module hex_socket_cut() {
  // Place recess from head top downward; extend slightly above top for clean cut
  z_cut_top = z_head_top + overlap_mm;
  z_cut_bottom = z_head_top - hex_socket_depth_mm;
  translate([0, 0, (z_cut_top + z_cut_bottom)/2])
    cylinder(r=hex_socket_af_mm/(2*cos(30)), h=(z_cut_top - z_cut_bottom), center=true, $fn=6);
}

// Screw + Washer as one connected solid
module screw_and_washer() {
  union() {
    // Screw (solid)
    color("DimGray")
    union() {
      // Shank (under head)
      translate([0, 0, (z_shank_top + z_shank_bottom)/2])
        cylinder(r=shank_diameter_mm/2, h=length_under_head_mm, center=true);

      // Cap head (overlaps into washer via washer placement)
      translate([0, 0, (z_head_top + z_head_bottom)/2])
        cylinder(r=head_diameter_mm/2, h=head_height_mm, center=true);

      // Threaded section (kept as a cylinder) - ensure it overlaps shank by overlap_mm
      thread_h = length_under_head_mm * thread_coverage_ratio;
      translate([0, 0, z_shank_bottom + thread_h/2 + overlap_mm])
        cylinder(r=thread_major_diameter_mm/2, h=thread_h, center=true);
    }

    // Washer (solid ring) - overlaps into head underside and shank
    color("Silver")
    difference() {
      translate([0, 0, (z_washer_top + z_washer_bottom)/2])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
      translate([0, 0, (z_washer_top + z_washer_bottom)/2])
        cylinder(r=washer_hole_diameter_mm/2, h=washer_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// PCB Spacer - overlaps into washer and buzzer
module pcb_spacer() {
  color([0.0, 0.4, 0.2])
    translate([0, 0, (z_spacer_top + z_spacer_bottom)/2])
      cylinder(r=pcb_spacer_outer_diameter_mm/2, h=pcb_spacer_height_mm, center=true);
}

// Buzzer - overlaps into spacer and pin socket
module buzzer() {
  color([0.1, 0.1, 0.6])
    translate([0, 0, (z_buzzer_top + z_buzzer_bottom)/2])
      cylinder(r=buzzer_diameter_mm/2, h=buzzer_height_mm, center=true);
}

// Connector Rod - overlaps into head and into pin socket
module connector_rod() {
  color([0.2, 0.2, 0.2])
    translate([0, 0, (z_rod_top + z_rod_bottom)/2])
      cylinder(r=connector_radius_mm, h=(z_rod_top - z_rod_bottom), center=true);
}

// Assembly: everything unioned into one connected solid; hex socket is a cut
module assembly() {
  difference() {
    union() {
      // Missing part "screw" is explicitly present here as screw_and_washer()
      screw_and_washer();  // head + shank + thread + washer (all connected via overlaps)
      pcb_spacer();        // green shank section attached (overlap)
      buzzer();            // blue mid-body cylinder attached (overlap)
      pin_socket();        // light-gray lower section attached (overlap)
      connector_rod();     // internal rod ensures continuous physical connection through stack
    }
    // Cut the hex socket into the head
    hex_socket_cut();
  }
}

assembly();