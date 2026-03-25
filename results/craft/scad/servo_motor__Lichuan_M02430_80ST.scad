$fn = 96;

// Parameters (approximate for Lichuan 80mm frame servo)
frame_size_mm = 80;                 //[40:160:1]
body_length_mm = 110;               //[55:220:1]
body_corner_radius_mm = 3;          //[1:8:0.5]

faceplate_thickness_mm = 8;         //[4:16:1]
pilot_diameter_mm = 60;             //[30:120:1]
pilot_depth_mm = 2;                 //[1:6:0.5]

mount_hole_diameter_mm = 6.6;       //[3:10:0.1]
mount_hole_pitch_mm = 66;           //[40:120:1]

shaft_diameter_mm = 19;             //[8:38:0.5]
shaft_length_mm = 40;               //[15:80:1]
shaft_flat_depth_mm = 1.0;          //[0.2:3:0.1]

rear_cap_diameter_mm = 72;          //[40:140:1]
rear_cap_length_mm = 12;            //[6:30:1]

connector_width_mm = 26;            //[12:50:1]
connector_height_mm = 18;           //[8:40:1]
connector_depth_mm = 14;            //[6:30:1]
connector_offset_from_rear_mm = 18; //[8:40:1]

overlap_mm = 1;                     //[0.5:2:0.1]

// Extra detail parameters (kept formula-based, no arbitrary placement)
front_boss_diameter_mm = 38;        // bearing/shaft boss on face
front_boss_height_mm   = 4;

rear_encoder_diameter_mm = 52;      // encoder/connector housing boss
rear_encoder_length_mm   = 18;

rear_rim_diameter_mm = 76;          // rear rim step
rear_rim_length_mm   = 4;

module rounded_box(size=[10,10,10], r=1) {
  // size is full size, centered
  minkowski() {
    cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
    sphere(r=r);
  }
}

module servo_motor() {
  // Coordinate system:
  // Front faceplate outer face at z=0, motor extends to negative z.
  // Shaft extends to positive z.

  // Derived positions
  body_zc = -(faceplate_thickness_mm + body_length_mm/2);
  face_zc = -faceplate_thickness_mm/2;

  rear_face_z = -(faceplate_thickness_mm + body_length_mm); // body rear plane
  rear_cap_zc = rear_face_z - rear_cap_length_mm/2 + overlap_mm;

  // Connector: attached to side of body, near rear
  conn_xc = frame_size_mm/2 + connector_width_mm/2 - overlap_mm;
  conn_zc = rear_face_z + connector_offset_from_rear_mm;

  // Front details
  pilot_zc = pilot_depth_mm/2 - overlap_mm;
  front_boss_zc = pilot_depth_mm + front_boss_height_mm/2 - overlap_mm;

  // Shaft
  shaft_zc = shaft_length_mm/2 - overlap_mm;

  // Rear details
  rear_encoder_zc = rear_face_z - rear_encoder_length_mm/2 + overlap_mm;
  rear_rim_zc = rear_face_z - rear_rim_length_mm/2 + overlap_mm;

  union() {
    // Motor body (rounded)
    color([0.15, 0.2, 0.35])
      translate([0,0,body_zc])
        rounded_box([frame_size_mm, frame_size_mm, body_length_mm], r=body_corner_radius_mm);

    // Front faceplate (with holes)
    color("Silver")
      difference() {
        translate([0,0,face_zc])
          cube([frame_size_mm, frame_size_mm, faceplate_thickness_mm], center=true);

        for (x = [-1, 1], y = [-1, 1])
          translate([x*mount_hole_pitch_mm/2, y*mount_hole_pitch_mm/2, face_zc])
            cylinder(r=mount_hole_diameter_mm/2, h=faceplate_thickness_mm + 2*overlap_mm, center=true);
      }

    // Pilot boss (front register)
    color("Silver")
      translate([0,0,pilot_zc])
        cylinder(r=pilot_diameter_mm/2, h=pilot_depth_mm, center=true);

    // Front bearing/shaft boss (distinct face detail)
    color("Silver")
      translate([0,0,front_boss_zc])
        cylinder(r=front_boss_diameter_mm/2, h=front_boss_height_mm, center=true);

    // Output shaft with flat
    color("Silver")
      difference() {
        translate([0,0,shaft_zc])
          cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

        // Flat cut: remove a slab from one side
        translate([shaft_diameter_mm/2 - shaft_flat_depth_mm, 0, shaft_zc])
          cube([shaft_diameter_mm, shaft_diameter_mm*2, shaft_length_mm + 2*overlap_mm], center=true);
      }

    // Rear cap (main rear cylinder)
    color([0.12, 0.16, 0.28])
      translate([0,0,rear_cap_zc])
        cylinder(r=rear_cap_diameter_mm/2, h=rear_cap_length_mm, center=true);

    // Rear rim step (small step near rear face)
    color([0.12, 0.16, 0.28])
      translate([0,0,rear_rim_zc])
        cylinder(r=rear_rim_diameter_mm/2, h=rear_rim_length_mm, center=true);

    // Rear encoder/connector housing boss (distinct rear feature)
    color([0.12, 0.16, 0.28])
      translate([0,0,rear_encoder_zc])
        cylinder(r=rear_encoder_diameter_mm/2, h=rear_encoder_length_mm, center=true);

    // Cable connector block (attached to side of body)
    color([0.20, 0.35, 0.60])
      translate([conn_xc, 0, conn_zc])
        cube([connector_width_mm, connector_depth_mm, connector_height_mm], center=true);
  }
}

// Assembly
servo_motor();