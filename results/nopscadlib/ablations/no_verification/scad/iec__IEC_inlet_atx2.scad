// Parameters
component_type = 0; //[0:0:1]
orientation = 0; //[0:0:1]
origin_x = 0; //[-100:100:1]
origin_y = 0; //[-100:100:1]
origin_z = 0; //[-100:100:1]
overlap = 1; //[0.5:2:0.1]
flange_w = 50; //[25:100:1]
flange_h = 28; //[14:56:1]
flange_t = 3; //[1.5:6:0.5]
bezel_w = 44; //[22:88:1]
bezel_h = 24; //[12:48:1]
bezel_t = 2; //[1:4:0.5]
body_w = 40; //[20:80:1]
body_h = 22; //[11:44:1]
body_depth_front = 14; //[7:28:1]
body_depth_rear = 18; //[9:36:1]
socket_w = 24.5; //[12.25:49:0.1]
socket_h = 16.34; //[8.17:32.68:0.01]
socket_depth = 17; //[8.5:34:1]
socket_offset_y = 0; //[-5:5:0.5]
screw_pitch_x = 40; //[20:80:1]
screw_pitch_y = 20; //[10:40:1]
screw_clear_r = 1.7; //[0.85:3.4:0.05]
countersink_r = 3.2; //[1.6:6.4:0.1]
countersink_h = 2; //[1:4:0.5]
pin_w = 2; //[1:4:0.1]
pin_d = 4; //[2:8:0.1]
pin_h_short = 12; //[6:24:1]
pin_h_long = 15; //[7.5:30:1]
pin_spacing_x = 7; //[3.5:14:0.5]
pin_offset_y = -2; //[-6:6:0.5]
pin_center_offset_y = 2; //[-6:6:0.5]

$fn = 64;

// IEC Connector - lugless, one connected solid
module iec() {
  // Build along Z with flange FRONT face at z=0, body extends to +Z
  z_flange_c = flange_t/2;
  z_bezel_c  = flange_t + bezel_t/2 - overlap;
  z_front_c  = flange_t + bezel_t + body_depth_front/2 - overlap;
  z_rear_c   = flange_t + bezel_t + body_depth_front + body_depth_rear/2 - overlap;

  total_depth = flange_t + bezel_t + body_depth_front + body_depth_rear;

  translate([origin_x, origin_y, origin_z])
  difference() {
    // ONE connected solid: union of all positive geometry
    union() {
      // Flange
      translate([0, 0, z_flange_c])
        cube([flange_w, flange_h, flange_t], center=true);

      // Bezel (overlaps into flange)
      translate([0, 0, z_bezel_c])
        cube([bezel_w, bezel_h, bezel_t], center=true);

      // Front body (overlaps into bezel)
      translate([0, 0, z_front_c])
        cube([body_w, body_h, body_depth_front], center=true);

      // Rear body (overlaps into front body)
      translate([0, 0, z_rear_c])
        cube([body_w, body_h, body_depth_rear], center=true);

      // Pins: ensure they are embedded into rear body (not floating)
      // Place pin centers slightly INSIDE the rear body's back face by 'overlap'
      z_pin_long_c  = z_rear_c + (body_depth_rear/2) - (pin_h_long/2) - overlap;
      z_pin_short_c = z_rear_c + (body_depth_rear/2) - (pin_h_short/2) - overlap;

      translate([0, socket_offset_y + pin_center_offset_y, z_pin_long_c])
        cube([pin_w, pin_d, pin_h_long], center=true);

      for (x = [-pin_spacing_x, pin_spacing_x])
        translate([x, socket_offset_y + pin_offset_y, z_pin_short_c])
          cube([pin_w, pin_d, pin_h_short], center=true);
    }

    // Socket opening: cut from FRONT face (z=0) into the body (+Z)
    // Centered so its front face is at z=0 (with a small overlap to avoid coplanar issues)
    translate([0, socket_offset_y, socket_depth/2 - overlap])
      cube([socket_w, socket_h, socket_depth + 2*overlap], center=true);

    // Screw clearance holes + countersinks
    for (x = [-screw_pitch_x/2, screw_pitch_x/2])
      for (y = [-screw_pitch_y/2, screw_pitch_y/2]) {
        // Through hole along Z, spanning entire part depth
        translate([x, y, total_depth/2 - overlap])
          cylinder(r=screw_clear_r, h=total_depth + 4*overlap, center=true);

        // Countersink from front side (within flange thickness)
        translate([x, y, countersink_h/2 - overlap])
          cylinder(r1=countersink_r, r2=0, h=countersink_h + 2*overlap, center=true);
      }
  }
}

// Assembly
module assembly() {
  iec();
}

assembly();