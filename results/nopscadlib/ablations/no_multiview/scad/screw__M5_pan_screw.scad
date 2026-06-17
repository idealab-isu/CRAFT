// Parameters
shaft_diameter = 5; //[2.5:10:0.1]
length_under_head = 10; //[5:20:0.1]
head_diameter = 10; //[5:20:0.1]
head_height = 3.95; //[2:8:0.05]
thread_depth = 0.35; //[0.15:0.8:0.05]
thread_pitch = 0.8; //[0.4:1.6:0.05]
thread_turns = 13; //[5:30:1]
drive_socket_radius = 3; //[1.5:5:0.1]
drive_socket_depth = 2; //[1:3.5:0.1]
drive_slot_width = 1; //[0.6:2:0.05]
washer_outer_diameter = 12; //[8:24:0.1]
washer_thickness = 1; //[0.5:3:0.1]
washer_hole_diameter = 5.5; //[5.1:7:0.1]
spacer_height = 6; //[3:15:0.1]
spacer_wall = 1.8; //[1:3.6:0.1]
spacer_clearance_diameter = 5.6; //[5.1:7:0.1]
buzzer_diameter = 12; //[8:24:0.1]
buzzer_height = 7; //[4:14:0.1]

// Use 1–2mm overlap to guarantee watertight connections
overlap = 1.2; //[0.3:2:0.1]

// --------------------
// Derived Z references
// --------------------
// Place the underside of the screw head at Z=0.
// Shaft extends downward (negative Z). Washer/spacer/buzzer stack below.
z_head_underside = 0;
z_head_top       = z_head_underside + head_height;
z_shaft_bottom   = z_head_underside - length_under_head;

// Washer sits directly under head with overlap into head/shaft
z_washer_top     = z_head_underside + overlap;
z_washer_bottom  = z_washer_top - washer_thickness;

// Spacer sits under washer with overlap
z_spacer_top     = z_washer_bottom + overlap;
z_spacer_bottom  = z_spacer_top - spacer_height;

// Buzzer sits under spacer with overlap (fixes floating black cylinder + gap)
z_buzzer_top     = z_spacer_bottom + overlap;
z_buzzer_bottom  = z_buzzer_top - buzzer_height;

// --------------------
// Screw (missing part) + washer
// --------------------
module screw_and_washer() {
  union() {
    // Screw body (shaft + head) as one solid
    color("DimGray")
    union() {
      // Shaft
      translate([0, 0, (z_head_underside + z_shaft_bottom)/2])
        cylinder(h=length_under_head, r=shaft_diameter/2, center=true, $fn=64);

      // Pan head
      translate([0, 0, (z_head_underside + z_head_top)/2])
        cylinder(h=head_height, r=head_diameter/2, center=true, $fn=64);
    }

    // Drive recess: subtract from head (kept as a recess, not a separate floating part)
    difference() {
      // Head again as subtraction target (only affects head volume)
      translate([0, 0, (z_head_underside + z_head_top)/2])
        cylinder(h=head_height, r=head_diameter/2, center=true, $fn=64);

      // Recess pocket
      translate([0, 0, z_head_top - drive_socket_depth/2])
        cylinder(h=drive_socket_depth + 0.2, r=drive_socket_radius, center=true, $fn=64);

      // Cross slot inside the pocket
      translate([0, 0, z_head_top - drive_socket_depth/2])
        union() {
          cube([2*drive_socket_radius, drive_slot_width, drive_socket_depth + 0.4], center=true);
          cube([drive_slot_width, 2*drive_socket_radius, drive_socket_depth + 0.4], center=true);
        }
    }

    // Washer (physically overlaps into head/shaft by 'overlap')
    color("DimGray")
    translate([0, 0, (z_washer_top + z_washer_bottom)/2])
      difference() {
        cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true, $fn=64);
        cylinder(h=washer_thickness + 2*overlap, r=washer_hole_diameter/2, center=true, $fn=64);
      }
  }
}

// --------------------
// PCB Spacer
// --------------------
module pcb_spacer() {
  color("Silver")
  translate([0, 0, (z_spacer_top + z_spacer_bottom)/2])
    difference() {
      cylinder(h=spacer_height, r=spacer_clearance_diameter/2 + spacer_wall, center=true, $fn=64);
      cylinder(h=spacer_height + 2*overlap, r=spacer_clearance_diameter/2, center=true, $fn=64);
    }
}

// --------------------
// Buzzer (black cylinder) - attached with overlap (no floating/gap)
// --------------------
module buzzer() {
  color("Black")
  translate([0, 0, (z_buzzer_top + z_buzzer_bottom)/2])
    cylinder(h=buzzer_height, r=buzzer_diameter/2, center=true, $fn=64);
}

// --------------------
// Assembly: single connected solid
// --------------------
module assembly() {
  union() {
    // Make the screw a single solid with its recess by subtracting recess from head
    // while keeping washer/spacer/buzzer unioned and overlapping.
    union() {
      // Screw+washer (includes head/shaft and washer)
      screw_and_washer();

      // Spacer and buzzer attached below with overlaps
      pcb_spacer();
      buzzer();
    }
  }
}

assembly();