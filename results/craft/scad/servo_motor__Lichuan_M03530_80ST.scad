$fn = 96;

// Parameters (approx. Lichuan 80mm frame servo)
frame_size_mm = 80; //[40:160:1]
housing_length_mm = 120; //[60:240:1]
housing_corner_radius_mm = 3; //[1:6:0.5]

faceplate_thickness_mm = 8; //[4:16:1]
flange_outer_diameter_mm = 90; //[70:140:1]
pilot_diameter_mm = 60; //[40:100:1]
pilot_height_mm = 2.5; //[1:6:0.5]

mount_hole_count = 4; //[4:4:1]
mount_hole_diameter_mm = 6.5; //[3:10:0.1]
mount_hole_pitch_mm = 70; //[50:110:1]

shaft_diameter_mm = 19; //[10:30:0.5]
shaft_length_mm = 40; //[15:80:1]
shaft_flat_depth_mm = 1; //[0.5:3:0.1]
shaft_flat_length_mm = 25; //[10:60:1]

rear_cap_diameter_mm = 78; //[50:140:1]
rear_cap_length_mm = 12; //[6:30:1]

connector_block_width_mm = 28; //[14:60:1]
connector_block_height_mm = 18; //[10:40:1]
connector_block_depth_mm = 16; //[8:40:1]
connector_offset_from_rear_mm = 18; //[8:50:1]

overlap_mm = 1; //[0.5:2:0.1]

// Extra detail parameters (kept dimension-driven)
front_boss_diameter_mm = 72;
front_boss_height_mm = 3;

rear_encoder_diameter_mm = 52;
rear_encoder_length_mm = 18;

tie_rod_diameter_mm = 6;
tie_rod_inset_mm = 10; // from outer edge of frame

// Connector / terminal box details (dimension-driven)
connector_neck_len_mm = 6;          // length from body side to box
connector_neck_w_mm   = 16;         // neck width (X)
connector_neck_d_mm   = 12;         // neck depth (Y)
connector_neck_h_mm   = 12;         // neck height (Z)

cable_gland_d_mm = 10;
cable_gland_len_mm = 10;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=true) {
  minkowski() {
    cube([max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)], center=center);
    sphere(r=r);
  }
}

module servo_motor() {
  // Coordinate convention:
  // Front faceplate centered at z=0, motor extends to negative z.
  z_front = 0;

  // Body extents
  z_body_front = z_front - faceplate_thickness_mm/2 + overlap_mm/2;
  z_body_back  = z_body_front - housing_length_mm;
  z_body_center = (z_body_front + z_body_back)/2;

  // Rear cap and encoder
  z_rearcap_center = z_body_back - rear_cap_length_mm/2 + overlap_mm/2;
  z_rearcap_back   = z_body_back - rear_cap_length_mm + overlap_mm/2;
  z_encoder_center = z_rearcap_back - rear_encoder_length_mm/2 + overlap_mm/2;

  // Connector block position (on side, near rear) - ensure connected via neck
  // Place connector box center so its inner face is beyond the neck outer face by overlap.
  x_body_side = frame_size_mm/2;
  x_neck_center = x_body_side + connector_neck_len_mm/2 - overlap_mm/2;
  x_box_center  = x_body_side + connector_neck_len_mm + connector_block_width_mm/2 - overlap_mm;

  // Put connector near rear, but still on the main housing length
  z_conn = z_body_back + connector_offset_from_rear_mm;
  z_conn = min(z_body_front - connector_block_height_mm/2, max(z_body_back + connector_block_height_mm/2, z_conn));

  // Tie-rod positions (near corners)
  rod_xy = frame_size_mm/2 - tie_rod_inset_mm;

  // Front features Z positions
  z_face_center = z_front;
  z_shaft_center = z_front + faceplate_thickness_mm/2 + shaft_length_mm/2 - overlap_mm/2;
  z_boss_center  = z_front + faceplate_thickness_mm/2 + front_boss_height_mm/2 - overlap_mm/2;
  z_pilot_center = z_front + faceplate_thickness_mm/2 + pilot_height_mm/2 - overlap_mm/2;

  // Bearing / seal ring (visual) on faceplate around shaft
  bearing_od_mm = min(pilot_diameter_mm*0.55, flange_outer_diameter_mm*0.55);
  bearing_id_mm = shaft_diameter_mm + 2;
  bearing_thk_mm = 2.2;

  union() {
    // Main housing (rounded square prism)
    color([0.15, 0.2, 0.35])
      translate([0,0,z_body_center])
        rounded_box([frame_size_mm, frame_size_mm, housing_length_mm], r=housing_corner_radius_mm, center=true);

    // Front faceplate flange (disc) with pilot and bolt holes
    color("Silver")
      difference() {
        union() {
          // Flange disc
          translate([0,0,z_face_center])
            cylinder(r=flange_outer_diameter_mm/2, h=faceplate_thickness_mm, center=true);

          // Front boss ring
          translate([0,0,z_boss_center])
            cylinder(r=front_boss_diameter_mm/2, h=front_boss_height_mm, center=true);

          // Pilot register
          translate([0,0,z_pilot_center])
            cylinder(r=pilot_diameter_mm/2, h=pilot_height_mm, center=true);

          // Bearing/seal ring (raised)
          translate([0,0,z_front + faceplate_thickness_mm/2 + bearing_thk_mm/2 - overlap_mm/2])
            difference() {
              cylinder(r=bearing_od_mm/2, h=bearing_thk_mm, center=true);
              cylinder(r=bearing_id_mm/2, h=bearing_thk_mm + 2*overlap_mm, center=true);
            }
        }

        // Mounting holes (4x)
        for (x = [-mount_hole_pitch_mm/2, mount_hole_pitch_mm/2])
          for (y = [-mount_hole_pitch_mm/2, mount_hole_pitch_mm/2])
            translate([x, y, z_face_center])
              cylinder(r=mount_hole_diameter_mm/2, h=faceplate_thickness_mm + 2*overlap_mm, center=true);

        // Tie-rod through holes (4x)
        for (x = [-rod_xy, rod_xy])
          for (y = [-rod_xy, rod_xy])
            translate([x, y, z_body_center])
              cylinder(r=(tie_rod_diameter_mm/2)*0.9,
                       h=housing_length_mm + faceplate_thickness_mm + rear_cap_length_mm + rear_encoder_length_mm + 6*overlap_mm,
                       center=true);
      }

    // Output shaft with flat
    color("Silver")
      difference() {
        translate([0,0,z_shaft_center])
          cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

        // Flat cut (D-shaft) near the tip (+X side)
        translate([shaft_diameter_mm/2 - shaft_flat_depth_mm/2, 0,
                   z_front + faceplate_thickness_mm/2 + shaft_length_mm - shaft_flat_length_mm/2])
          cube([shaft_diameter_mm, shaft_diameter_mm*1.4, shaft_flat_length_mm + 2*overlap_mm], center=true);
      }

    // Rear cap / endbell
    color("Silver")
      translate([0,0,z_rearcap_center])
        cylinder(r=rear_cap_diameter_mm/2, h=rear_cap_length_mm, center=true);

    // Rear encoder housing (smaller cylinder) connected to rear cap
    color([0.75,0.75,0.78])
      translate([0,0,z_encoder_center])
        cylinder(r=rear_encoder_diameter_mm/2, h=rear_encoder_length_mm, center=true);

    // Tie rods (external) running along body
    color([0.65,0.65,0.68])
      for (x = [-rod_xy, rod_xy])
        for (y = [-rod_xy, rod_xy])
          translate([x, y, z_body_center])
            cylinder(r=tie_rod_diameter_mm/2,
                     h=housing_length_mm + faceplate_thickness_mm + rear_cap_length_mm - overlap_mm,
                     center=true);

    // Connector neck (ensures robust connection to body)
    color("Black")
      translate([x_neck_center, 0, z_conn])
        rounded_box([connector_neck_len_mm, connector_neck_d_mm, connector_neck_h_mm], r=1.0, center=true);

    // Connector / terminal box (side) connected to neck with overlap
    color("Black")
      translate([x_box_center, 0, z_conn])
        rounded_box([connector_block_width_mm, connector_block_depth_mm, connector_block_height_mm], r=1.2, center=true);

    // Cable gland / strain relief on connector box outer face (cylindrical)
    // Outer face of box at x = x_box_center + connector_block_width/2
    color("Black")
      translate([x_box_center + connector_block_width_mm/2 + cable_gland_len_mm/2 - overlap_mm/2, 0, z_conn])
        rotate([0,90,0])
          cylinder(r=cable_gland_d_mm/2, h=cable_gland_len_mm, center=true);
  }
}

// Assembly
servo_motor();