// Parameters
component_type_lugless = 1; //[1:1:1]
gender_unspecified = 1; //[0:1:1]
include_can_filter_auto = 0; //[0:1:1]
flange_width = 50; //[25:100:1]
flange_height = 28; //[14:56:1]
flange_thickness = 3; //[2:6:1]
bezel_width = 44; //[22:88:1]
bezel_height = 24; //[12:48:1]
bezel_thickness = 2; //[1:5:1]
depth = 28; //[14:56:1]
body_width = 40; //[20:80:1]
body_height = 22; //[11:44:1]
socket_width = 24.5; //[12:49:0.5]
socket_height = 16.34; //[8:33:0.5]
socket_depth = 17; //[9:34:1]
socket_offset_y = 0; //[-6:6:1]
screw_pitch_x = 40; //[20:80:1]
screw_pitch_y = 20; //[10:40:1]
screw_clearance_d = 3.5; //[2:7:0.1]
overlap = 1; //[0.5:2:0.5]

$fn = 64;

// Helpers
module rbox(size=[10,10,10], r=1, center=true) {
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = min(r, sx/2, sy/2);
  hull() {
    for (ix=[-1,1], iy=[-1,1])
      translate([ix*(sx/2-rr), iy*(sy/2-rr), 0])
        cylinder(r=rr, h=sz, center=center);
  }
}

module iec_lugless() {
  // Coordinate system: Z+ goes "rearward" (into device). Front face at z=0.

  // Derived lengths/positions (all formulas)
  rear_len = max(0, depth - socket_depth);

  z_flange_c = flange_thickness/2;
  z_bezel_c  = flange_thickness + bezel_thickness/2 - overlap;
  z_body_c   = flange_thickness + bezel_thickness + socket_depth/2 - overlap;
  z_rear_c   = flange_thickness + bezel_thickness + socket_depth + rear_len/2 - overlap;

  // Cuts
  cut_h     = flange_thickness + bezel_thickness + socket_depth + 2*overlap;
  z_cut_c   = cut_h/2 - overlap;

  recess_h    = min(2.0, flange_thickness + bezel_thickness);
  z_recess_c  = recess_h/2 - overlap;

  // IEC-ish pin openings (3 slots)
  pin_w = socket_width * 0.18;
  pin_h = socket_height * 0.28;
  pin_pitch_x = socket_width * 0.28;
  pin_y = socket_offset_y + socket_height * 0.12;

  gnd_w = pin_w * 0.9;
  gnd_h = pin_h * 0.9;
  gnd_y = socket_offset_y - socket_height * 0.18;

  pin_cut_h   = socket_depth * 0.75 + 2*overlap;
  z_pin_cut_c = flange_thickness + bezel_thickness + pin_cut_h/2 - overlap;

  // Lugless: no rear terminals/lugs; rear is smooth housing only.
  difference() {
    union() {
      // Single connected outer solid (flange + bezel + body + rear)
      translate([0, 0, z_flange_c])
        rbox([flange_width, flange_height, flange_thickness], r=1.2, center=true);

      translate([0, 0, z_bezel_c])
        rbox([bezel_width, bezel_height, bezel_thickness], r=1.0, center=true);

      translate([0, 0, z_body_c])
        rbox([body_width, body_height, socket_depth], r=1.2, center=true);

      if (rear_len > 0)
        translate([0, 0, z_rear_c])
          rbox([body_width, body_height, rear_len], r=1.2, center=true);

      // Rear bump integrated (overlaps into rear section to ensure connectivity)
      bump_r = min(body_height, body_width) * 0.18;
      bump_h = max(2, rear_len * 0.35);
      z_bump_c = flange_thickness + bezel_thickness + depth - bump_h/2 - overlap;
      translate([0, 0, z_bump_c])
        cylinder(r=bump_r, h=bump_h, center=true);
    }

    // Main socket orifice (rectangular opening)
    translate([0, socket_offset_y, z_cut_c])
      rbox([socket_width, socket_height, cut_h], r=1.0, center=true);

    // Front recess / bevel (larger shallow pocket)
    translate([0, socket_offset_y, z_recess_c])
      rbox([socket_width*1.08, socket_height*1.08, recess_h + 2*overlap], r=1.6, center=true);

    // Pin openings (3 slots)
    for (sx = [-1, 1])
      translate([sx*pin_pitch_x, pin_y, z_pin_cut_c])
        rbox([pin_w, pin_h, pin_cut_h], r=min(0.6, pin_w/3), center=true);

    translate([0, gnd_y, z_pin_cut_c])
      rbox([gnd_w, gnd_h, pin_cut_h], r=min(0.6, gnd_w/3), center=true);

    // Mounting screw holes (through flange+bezel only)
    screw_h = flange_thickness + bezel_thickness + 2*overlap;
    z_screw_c = screw_h/2 - overlap;
    for (x = [-screw_pitch_x/2, screw_pitch_x/2])
      for (y = [-screw_pitch_y/2, screw_pitch_y/2])
        translate([x, y, z_screw_c])
          cylinder(d=screw_clearance_d, h=screw_h, center=true);
  }
}

// Assembly
module assembly() {
  iec_lugless();
}

assembly();