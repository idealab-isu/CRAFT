// Parameters
motor_frame_size_mm = 80; //[40:160:1]
body_length_mm = 110; //[55:220:1]
body_corner_radius_mm = 2; //[0.5:6:0.5]
flange_size_mm = 90; //[70:140:1]
flange_thickness_mm = 6; //[3:15:1]
pilot_diameter_mm = 60; //[40:100:1]
pilot_height_mm = 2; //[1:6:0.5]
shaft_diameter_mm = 19; //[8:35:0.5]
shaft_length_mm = 40; //[15:80:1]
shaft_flat_width_mm = 16; //[8:30:0.5]
shaft_flat_depth_mm = 1.0; //[0.2:4:0.1]
mount_hole_diameter_mm = 6.5; //[3:12:0.1]
mount_hole_pitch_mm = 70; //[40:120:1]
rear_cap_diameter_mm = 78; //[50:140:1]
rear_cap_length_mm = 12; //[6:30:1]
connector_boss_width_mm = 26; //[12:60:1]
connector_boss_height_mm = 18; //[8:50:1]
connector_boss_depth_mm = 14; //[6:40:1]
connector_boss_offset_from_rear_mm = 20; //[5:60:1]
tolerance_clearance_mm = 0.2; //[0:1:0.05]
overlap_mm = 1.5; //[0.5:2:0.1]  // use 1-2mm overlap for robust unions

// Servo Motor - complete geometry (fixed connectivity)
module servo_motor() {
  // Precompute key faces (Z axis is motor length)
  body_front_z =  body_length_mm/2;
  body_rear_z  = -body_length_mm/2;

  // Flange: overlap into body by overlap_mm
  flange_back_z   = body_front_z - overlap_mm;
  flange_front_z  = flange_back_z + flange_thickness_mm;
  flange_center_z = (flange_back_z + flange_front_z)/2;

  // Pilot: overlap into flange by overlap_mm
  pilot_back_z   = flange_front_z - overlap_mm;
  pilot_front_z  = pilot_back_z + pilot_height_mm;
  pilot_center_z = (pilot_back_z + pilot_front_z)/2;

  // Shaft: overlap into pilot by overlap_mm (guarantees no gap at interface)
  shaft_back_z   = pilot_front_z - overlap_mm;
  shaft_front_z  = shaft_back_z + shaft_length_mm;
  shaft_center_z = (shaft_back_z + shaft_front_z)/2;

  // Rear cap: overlap into body by overlap_mm
  rearcap_front_z  = body_rear_z + overlap_mm;
  rearcap_back_z   = rearcap_front_z - rear_cap_length_mm;
  rear_center_z    = (rearcap_front_z + rearcap_back_z)/2;

  // Connector boss: overlap into +Y face by overlap_mm
  body_posY = motor_frame_size_mm/2;
  boss_minY = body_posY - overlap_mm;                 // boss -Y face inside body
  boss_center_y = boss_minY + connector_boss_depth_mm/2;

  // Keep original Z intent (offset from rear), but ensure it intersects body in Z too
  // Place boss center at requested offset, then clamp so it stays within body span.
  boss_center_z_raw = body_rear_z + connector_boss_offset_from_rear_mm;
  boss_half_h = connector_boss_height_mm/2;
  boss_center_z = min(body_front_z - boss_half_h + overlap_mm,
                  max(body_rear_z + boss_half_h - overlap_mm, boss_center_z_raw));

  color([0.15, 0.2, 0.35])
  union() {

    // --- Main body ---
    cube([motor_frame_size_mm, motor_frame_size_mm, body_length_mm], center=true);

    // --- Front flange (with mounting holes) ---
    difference() {
      translate([0, 0, flange_center_z])
        cube([flange_size_mm, flange_size_mm, flange_thickness_mm], center=true);

      for (x = [-mount_hole_pitch_mm/2, mount_hole_pitch_mm/2])
        for (y = [-mount_hole_pitch_mm/2, mount_hole_pitch_mm/2])
          translate([x, y, flange_center_z])
            cylinder(r=mount_hole_diameter_mm/2,
                     h=flange_thickness_mm + pilot_height_mm + overlap_mm*6,
                     center=true);
    }

    // --- Front pilot (register) ---
    translate([0, 0, pilot_center_z])
      cylinder(r=pilot_diameter_mm/2, h=pilot_height_mm, center=true);

    // --- Output shaft with flat (FORCED to be attached via overlap into pilot) ---
    // This fixes the reported floating/disconnected thin central rod by ensuring
    // the shaft back face penetrates the pilot by overlap_mm.
    difference() {
      translate([0, 0, shaft_center_z])
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

      // Flat cut
      translate([shaft_diameter_mm/2 + shaft_flat_depth_mm, 0, shaft_center_z])
        cube([shaft_diameter_mm*2, shaft_diameter_mm*2, shaft_length_mm + overlap_mm*4], center=true);
    }

    // --- Rear cap ---
    translate([0, 0, rear_center_z])
      cylinder(r=rear_cap_diameter_mm/2, h=rear_cap_length_mm, center=true);

    // --- Cable connector boss ---
    translate([0, boss_center_y, boss_center_z])
      cube([connector_boss_width_mm, connector_boss_depth_mm, connector_boss_height_mm], center=true);
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();