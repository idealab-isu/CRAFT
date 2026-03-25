$fn = 96;

// -------------------- Parameters --------------------
frame_size_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]
corner_radius_mm = 2; //[0:6:0.5]

faceplate_thickness_mm = 6; //[3:12:0.5]
pilot_diameter_mm = 50; //[25:100:0.5]
pilot_height_mm = 2; //[1:6:0.5]

shaft_diameter_mm = 19; //[9.5:38:0.5]
shaft_length_mm = 40; //[20:80:1]
shaft_flat_depth_mm = 1; //[0.5:3:0.1]
shaft_flat_length_mm = 25; //[10:60:1]

mount_hole_diameter_mm = 6.6; //[3:10:0.1]
mount_hole_square_pitch_mm = 65; //[40:120:0.5]

rear_endcap_thickness_mm = 6; //[3:12:0.5]

// Connector/terminal box (rear-side)
connector_block_width_mm = 34; //[13:60:1]
connector_block_height_mm = 22; //[9:45:1]
connector_block_depth_mm = 18; //[7:40:1]
connector_offset_x_mm = 0; //[-20:20:1]
connector_offset_y_mm = 0; //[-20:20:1]

// Extra servo features (typical 80mm frame servo)
flange_ear_extra_mm = 10; //[0:20:1]     // mounting ear extension beyond frame
flange_ear_thickness_mm = 6; //[3:12:0.5]
flange_ear_hole_diameter_mm = 9; //[5:14:0.5]
flange_ear_hole_pitch_x_mm = 90; //[70:120:0.5]  // ear hole spacing (left-right)
flange_ear_hole_pitch_y_mm = 70; //[50:110:0.5]  // ear hole spacing (up-down)

rear_boss_diameter_mm = 38; //[20:70:0.5]
rear_boss_length_mm = 10; //[5:25:0.5]

front_recess_diameter_mm = 62; //[40:90:0.5]
front_recess_depth_mm = 1.2; //[0.5:4:0.1]

overlap_mm = 1; //[0.5:2:0.1]

// -------------------- Derived --------------------
body_w = frame_size_mm;
body_h = frame_size_mm;
body_l = body_length_mm;

flange_w = frame_size_mm;
flange_h = frame_size_mm;
flange_t = faceplate_thickness_mm;

rear_cap_t = rear_endcap_thickness_mm;

shaft_r = shaft_diameter_mm/2;
shaft_l = shaft_length_mm;

front_boss_r = pilot_diameter_mm/2;
front_boss_h = pilot_height_mm;

rear_boss_r = rear_boss_diameter_mm/2;
rear_boss_l = rear_boss_length_mm;

ear_w = flange_w + 2*flange_ear_extra_mm;
ear_h = flange_h + 2*flange_ear_extra_mm;
ear_t = flange_ear_thickness_mm;

front_face_z = body_l/2 + flange_t/2 - overlap_mm;
rear_face_z  = -body_l/2 - rear_cap_t/2 + overlap_mm;

// -------------------- Helpers --------------------
module rounded_box(size=[10,10,10], r=1, center=true) {
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = min(r, sx/2, sy/2, sz/2);
  translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    minkowski() {
      cube([sx-2*rr, sy-2*rr, sz-2*rr], center=true);
      sphere(r=rr);
    }
}

module servo_motor() {
  // One connected solid: union of all positive geometry, then subtract holes/details.
  difference() {
    union() {
      // Main body (rounded)
      rounded_box([body_w, body_h, body_l], r=corner_radius_mm, center=true);

      // Front faceplate (square)
      translate([0,0, body_l/2 + flange_t/2 - overlap_mm])
        rounded_box([flange_w, flange_h, flange_t], r=corner_radius_mm, center=true);

      // Mounting ears/flange (wider than body) - connected to faceplate
      translate([0,0, body_l/2 + ear_t/2 - overlap_mm])
        rounded_box([ear_w, ear_h, ear_t], r=corner_radius_mm, center=true);

      // Front pilot boss (register)
      translate([0,0, body_l/2 + flange_t - overlap_mm + front_boss_h/2])
        cylinder(r=front_boss_r, h=front_boss_h, center=true);

      // Output shaft
      translate([0,0, body_l/2 + flange_t - overlap_mm + shaft_l/2])
        cylinder(r=shaft_r, h=shaft_l, center=true);

      // Rear endcap
      translate([0,0, -body_l/2 - rear_cap_t/2 + overlap_mm])
        rounded_box([body_w, body_h, rear_cap_t], r=corner_radius_mm, center=true);

      // Rear boss (encoder/cover cylinder) - connected to rear cap
      translate([0,0, -body_l/2 - rear_cap_t + overlap_mm - rear_boss_l/2])
        cylinder(r=rear_boss_r, h=rear_boss_l, center=true);

      // Connector/terminal box on rear cap (connected)
      // Place it on the rear cap face, protruding outward in -Z direction.
      translate([
        connector_offset_x_mm,
        connector_offset_y_mm,
        (-body_l/2 - rear_cap_t + overlap_mm) - connector_block_depth_mm/2 + overlap_mm
      ])
        rounded_box(
          [connector_block_width_mm, connector_block_height_mm, connector_block_depth_mm],
          r=min(2, min(connector_block_width_mm, connector_block_height_mm)/8),
          center=true
        );

      // Small rear cable strain relief nub (connected to connector box)
      nub_r = min(6, connector_block_height_mm*0.22);
      nub_l = max(8, connector_block_depth_mm*0.55);
      translate([
        connector_offset_x_mm + connector_block_width_mm/2 - nub_r - 1,
        connector_offset_y_mm,
        (-body_l/2 - rear_cap_t + overlap_mm) - connector_block_depth_mm + nub_l/2
      ])
        cylinder(r=nub_r, h=nub_l, center=true);
    }

    // -------------------- Subtractions --------------------

    // Front flange corner mounting holes (through faceplate)
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x*mount_hole_square_pitch_mm/2, y*mount_hole_square_pitch_mm/2, front_face_z])
        cylinder(r=mount_hole_diameter_mm/2, h=flange_t + 6*overlap_mm, center=true);
    }

    // Mounting ear holes (through ears)
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x*flange_ear_hole_pitch_x_mm/2, y*flange_ear_hole_pitch_y_mm/2, body_l/2 + ear_t/2 - overlap_mm])
        cylinder(r=flange_ear_hole_diameter_mm/2, h=ear_t + 6*overlap_mm, center=true);
    }

    // Front face recess ring (gives recognizable front face detail)
    translate([0,0, body_l/2 + flange_t - front_recess_depth_mm/2 + overlap_mm])
      cylinder(r=front_recess_diameter_mm/2, h=front_recess_depth_mm + 2*overlap_mm, center=true);

    // Shaft flat (cut near shaft end)
    translate([
      shaft_r - shaft_flat_depth_mm/2,
      0,
      (body_l/2 + flange_t - overlap_mm) + (shaft_l - shaft_flat_length_mm/2)
    ])
      cube([shaft_diameter_mm + 4*overlap_mm, shaft_diameter_mm + 4*overlap_mm, shaft_flat_length_mm + 6*overlap_mm], center=true);

    // Rear cap screw holes (typical rear cover screws) - shallow
    rear_screw_r = 2.2;
    rear_screw_pitch = frame_size_mm*0.62;
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x*rear_screw_pitch/2, y*rear_screw_pitch/2, rear_face_z])
        cylinder(r=rear_screw_r, h=rear_cap_t + 6*overlap_mm, center=true);
    }
  }
}

// Assembly
servo_motor();