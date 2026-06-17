// Lichuan -80M02430B (approximate) - single connected solid
$fn = 96;

// Parameters
motor_frame_size_mm = 80; //[60:120:1]
body_length_mm = 110; //[70:200:1]
corner_radius_mm = 2; //[1:6:0.5]
flange_thickness_mm = 8; //[4:16:1]
flange_size_mm = 90; //[70:130:1]
pilot_diameter_mm = 60; //[40:90:1]
pilot_depth_mm = 2; //[1:6:0.5]
shaft_diameter_mm = 19; //[10:30:0.5]
shaft_length_mm = 40; //[20:80:1]
shaft_flat_depth_mm = 1.5; //[0.5:4:0.25]
shaft_flat_length_mm = 25; //[10:60:1]
mount_hole_count = 4; //[4:4:1]
mount_hole_diameter_mm = 6.5; //[3:10:0.5]
mount_hole_square_pitch_mm = 70; //[50:100:1]
rear_cap_length_mm = 18; //[10:40:1]
rear_cap_diameter_mm = 78; //[60:110:1]
connector_width_mm = 28; //[15:60:1]
connector_height_mm = 18; //[10:40:1]
connector_depth_mm = 14; //[8:30:1]
overlap_mm = 1; //[0.5:2:0.5]

// Helpers
module rounded_box(size=[10,10,10], r=1, center=true) {
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = min(r, min(sx, sy)/2 - 0.01);
  if (rr <= 0) {
    cube(size, center=center);
  } else {
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
      hull() {
        for (x = [-1, 1])
          for (y = [-1, 1])
            translate([x*(sx/2-rr), y*(sy/2-rr), 0])
              cylinder(r=rr, h=sz, center=true);
      }
  }
}

module servo_motor() {
  // Body centered at origin along Z
  z_body_front =  body_length_mm/2;
  z_body_back  = -body_length_mm/2;

  // Place parts by dimension-derived formulas so they TOUCH/OVERLAP (never float)
  z_flange  = z_body_front + flange_thickness_mm/2 - overlap_mm;
  z_pilot   = (z_body_front + flange_thickness_mm - overlap_mm) + pilot_depth_mm/2 - overlap_mm;
  z_shaft   = (z_body_front + flange_thickness_mm - overlap_mm + pilot_depth_mm - overlap_mm) + shaft_length_mm/2 - overlap_mm;

  z_rearcap = z_body_back - rear_cap_length_mm/2 + overlap_mm;

  // Connector attached to rear cap (behind it), overlapping slightly
  z_rearcap_back_face = z_body_back - rear_cap_length_mm + overlap_mm; // back face of rear cap (approx)
  z_conn = z_rearcap_back_face - connector_depth_mm/2 + overlap_mm;

  // Build as ONE connected solid: union of solids, then subtract holes/flat
  difference() {
    union() {
      // Motor Body
      rounded_box([motor_frame_size_mm, motor_frame_size_mm, body_length_mm],
                  r=corner_radius_mm, center=true);

      // Front Flange
      translate([0, 0, z_flange])
        rounded_box([flange_size_mm, flange_size_mm, flange_thickness_mm],
                    r=corner_radius_mm, center=true);

      // Front Pilot
      translate([0, 0, z_pilot])
        cylinder(r=pilot_diameter_mm/2, h=pilot_depth_mm, center=true);

      // Output Shaft
      translate([0, 0, z_shaft])
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

      // Rear Cap
      translate([0, 0, z_rearcap])
        cylinder(r=rear_cap_diameter_mm/2, h=rear_cap_length_mm, center=true);

      // Cable Connector Boss
      translate([0, 0, z_conn])
        rounded_box([connector_width_mm, connector_height_mm, connector_depth_mm],
                    r=1, center=true);
    }

    // Mounting holes (cut through flange + pilot)
    hole_h = flange_thickness_mm + pilot_depth_mm + overlap_mm*8;
    z_holes = z_flange; // centered on flange
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * mount_hole_square_pitch_mm/2,
                   y * mount_hole_square_pitch_mm/2,
                   z_holes])
          cylinder(r=mount_hole_diameter_mm/2, h=hole_h, center=true, $fn=48);

    // Shaft flat: subtract a box that intersects the shaft near the tip
    shaft_r = shaft_diameter_mm/2;
    flat_offset_from_center = shaft_r - shaft_flat_depth_mm; // distance from shaft center to flat plane

    // Front end of shaft (absolute Z)
    z_shaft_front = (z_body_front + flange_thickness_mm - overlap_mm + pilot_depth_mm - overlap_mm)
                    + shaft_length_mm - overlap_mm;

    // Center the flat cut along the last shaft_flat_length_mm
    z_flat = z_shaft_front - shaft_flat_length_mm/2;

    // Place cutter so its face is at x = flat_offset_from_center (creates flat depth)
    // Using a large cube shifted so it removes material for x > flat_offset_from_center.
    translate([flat_offset_from_center + (shaft_diameter_mm*2)/2, 0, z_flat])
      cube([shaft_diameter_mm*2, shaft_diameter_mm*2, shaft_flat_length_mm + overlap_mm*4],
           center=true);
  }
}

// Assembly
servo_motor();