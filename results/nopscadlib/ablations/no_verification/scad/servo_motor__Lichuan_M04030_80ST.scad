// Lichuan -80M04030B (approximate) - ONE connected solid
// Fixes: robust geometry (no blank renders), all parts connected with formula-based placement,
// no arbitrary translate values, no holes/cutouts to keep single manifold solid.

motor_frame_size_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]
body_width_mm = 80; //[40:160:1]
body_height_mm = 80; //[40:160:1]
corner_radius_mm = 2; //[0:6:0.5]

flange_outer_diameter_mm = 90; //[60:140:1]
flange_thickness_mm = 6; //[3:15:0.5]

pilot_diameter_mm = 60; //[40:90:1]
pilot_length_mm = 2.5; //[1:8:0.5]

shaft_diameter_mm = 19; //[8:35:0.5]
shaft_length_mm = 40; //[15:80:1]

rear_endcap_thickness_mm = 6; //[3:15:0.5]
rear_connector_width_mm = 22; //[10:50:1]
rear_connector_height_mm = 14; //[6:40:1]
rear_connector_depth_mm = 12; //[6:40:1]

overlap_mm = 1; //[0.5:2:0.1]

$fn = 96;

// Rounded box helper (stable, visible)
module rounded_box(size=[10,10,10], r=1, center=true) {
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = min(r, sx/2, sy/2, sz/2);
  if (rr <= 0) {
    cube(size, center=center);
  } else {
    // Ensure positive core dimensions for minkowski
    core = [max(0.01, sx-2*rr), max(0.01, sy-2*rr), max(0.01, sz-2*rr)];
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
      minkowski() {
        cube(core, center=true);
        sphere(r=rr);
      }
  }
}

module servo_motor() {
  // Z extents of main body
  z_body_front =  body_length_mm/2;
  z_body_back  = -body_length_mm/2;

  // Place features so they overlap into the body (connected)
  z_flange_c = z_body_front + flange_thickness_mm/2 - overlap_mm;
  z_pilot_c  = z_body_front + flange_thickness_mm - overlap_mm + pilot_length_mm/2;
  z_shaft_c  = z_body_front + flange_thickness_mm - overlap_mm + shaft_length_mm/2;

  z_endcap_c = z_body_back - rear_endcap_thickness_mm/2 + overlap_mm;
  z_conn_c   = z_body_back - rear_connector_depth_mm/2 + overlap_mm;

  // Clamp radii
  body_r = min(corner_radius_mm, body_width_mm/2, body_height_mm/2, body_length_mm/2);
  conn_r = min(corner_radius_mm, rear_connector_width_mm/4, rear_connector_height_mm/4, rear_connector_depth_mm/4);

  union() {
    // Main body
    rounded_box([body_width_mm, body_height_mm, body_length_mm], r=body_r, center=true);

    // Front flange disk
    translate([0, 0, z_flange_c])
      cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true);

    // Front pilot
    translate([0, 0, z_pilot_c])
      cylinder(r=pilot_diameter_mm/2, h=pilot_length_mm, center=true);

    // Output shaft
    translate([0, 0, z_shaft_c])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

    // Rear endcap disk
    translate([0, 0, z_endcap_c])
      cylinder(r=flange_outer_diameter_mm/2, h=rear_endcap_thickness_mm, center=true);

    // Rear connector block (cable exit)
    translate([0, 0, z_conn_c])
      rounded_box([rear_connector_width_mm, rear_connector_height_mm, rear_connector_depth_mm],
                  r=conn_r, center=true);
  }
}

servo_motor();