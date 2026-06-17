// Lichuan -80M03530B (approximate) - single connected solid
// All placements are formula-based; all parts overlap slightly to ensure connectivity.

$fn = 64;

// Parameters
frame_size_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]
housing_width_mm = 80; //[40:160:1]
housing_height_mm = 80; //[40:160:1]
front_flange_thickness_mm = 8; //[4:16:0.5]
rear_cap_thickness_mm = 6; //[3:12:0.5]
pilot_diameter_mm = 65; //[32.5:130:0.5]
pilot_height_mm = 2.5; //[1:6:0.1]
shaft_diameter_mm = 19; //[9.5:38:0.5]
shaft_extension_mm = 40; //[20:80:1]
shaft_shoulder_diameter_mm = 22; //[11:44:0.5]
shaft_shoulder_length_mm = 6; //[2:20:0.5]
mount_hole_count = 4; //[4:4:1]
mount_hole_diameter_mm = 6.6; //[3.3:13.2:0.1]
mount_hole_square_pitch_mm = 63; //[31.5:126:0.5]
corner_radius_mm = 3; //[0:10:0.5]
connector_width_mm = 30; //[15:60:1]
connector_height_mm = 20; //[10:40:1]
connector_depth_mm = 15; //[8:30:1]
connector_offset_from_center_mm = 30; //[10:60:1]
shaft_flat_depth_mm = 1.0; //[0.2:3.0:0.1]
shaft_flat_length_mm = 25; //[10:60:1]
overlap_mm = 1; //[0.5:2:0.1]

// Helpers
module rounded_box(size=[10,10,10], r=0, center=true) {
  r2 = min(r, min(size[0], min(size[1], size[2]))/2);
  if (r2 <= 0) {
    cube(size, center=center);
  } else {
    // Robust rounded box using hull of corner spheres (avoids minkowski degeneracy/blank renders)
    sx = size[0]; sy = size[1]; sz = size[2];
    dx = sx/2 - r2;
    dy = sy/2 - r2;
    dz = sz/2 - r2;

    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
      hull() {
        for (ix = [-1, 1], iy = [-1, 1], iz = [-1, 1])
          translate([ix*dx, iy*dy, iz*dz]) sphere(r=r2);
      }
  }
}

// Servo Motor - complete geometry (ONE connected solid)
module servo_motor() {

  // Key Z reference planes (housing centered at z=0)
  z_front_face =  body_length_mm/2;
  z_rear_face  = -body_length_mm/2;

  // Flange and pilot positions (all overlap into previous part)
  z_flange_center = z_front_face + front_flange_thickness_mm/2 - overlap_mm;
  z_pilot_center  = z_front_face + front_flange_thickness_mm - overlap_mm + pilot_height_mm/2;

  // Shaft positions (shoulder starts at flange front face)
  z_shoulder_center = z_front_face + front_flange_thickness_mm - overlap_mm + shaft_shoulder_length_mm/2;
  z_shaft_center    = z_front_face + front_flange_thickness_mm - overlap_mm + shaft_extension_mm/2;

  // Rear cap position (overlap into housing)
  z_rear_cap_center = z_rear_face - rear_cap_thickness_mm/2 + overlap_mm;

  // Connector: attach to side of housing and overlap into it
  x_conn_center = housing_width_mm/2 + connector_width_mm/2 - overlap_mm;
  z_conn_center = z_rear_face + connector_depth_mm/2 - overlap_mm;

  // Build as a single union with holes subtracted (difference)
  difference() {
    union() {
      // Motor housing
      rounded_box([housing_width_mm, housing_height_mm, body_length_mm], r=corner_radius_mm, center=true);

      // Front flange faceplate
      translate([0, 0, z_flange_center])
        rounded_box([housing_width_mm, housing_height_mm, front_flange_thickness_mm], r=corner_radius_mm, center=true);

      // Pilot register boss
      translate([0, 0, z_pilot_center])
        cylinder(r=pilot_diameter_mm/2, h=pilot_height_mm, center=true);

      // Rear cap endbell
      translate([0, 0, z_rear_cap_center])
        rounded_box([housing_width_mm, housing_height_mm, rear_cap_thickness_mm], r=corner_radius_mm, center=true);

      // Cable connector block (side-mounted, connected)
      translate([x_conn_center, 0, z_conn_center])
        rounded_box([connector_width_mm, connector_height_mm, connector_depth_mm],
                    r=min(corner_radius_mm, 2), center=true);

      // Output shaft with shoulder (connected to flange/pilot via overlap)
      // Shoulder
      translate([0, 0, z_shoulder_center])
        cylinder(r=shaft_shoulder_diameter_mm/2, h=shaft_shoulder_length_mm, center=true, $fn=48);

      // Main shaft
      translate([0, 0, z_shaft_center])
        cylinder(r=shaft_diameter_mm/2, h=shaft_extension_mm, center=true, $fn=48);
    }

    // Subtract mounting holes through the front flange
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_hole_square_pitch_mm/2,
                 y * mount_hole_square_pitch_mm/2,
                 z_flange_center])
        cylinder(r=mount_hole_diameter_mm/2,
                 h=front_flange_thickness_mm + 2*overlap_mm,
                 center=true,
                 $fn=48);
    }

    // Subtract D-flat on shaft (cut a plane into the shaft)
    flat_x = (shaft_diameter_mm/2) - shaft_flat_depth_mm; // plane location from center
    z_flat_center = (z_front_face + front_flange_thickness_mm - overlap_mm)
                    + (shaft_extension_mm - shaft_flat_length_mm/2);

    translate([flat_x + 500, 0, z_flat_center])
      cube([1000, shaft_diameter_mm*3, shaft_flat_length_mm + 2*overlap_mm], center=true);
  }
}

// Assembly
servo_motor();