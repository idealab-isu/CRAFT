$fn = 96;

// Parameters
shell_W = 30; //[15:60:1]
shell_H = 12; //[6:24:1]
shell_D = 18; //[9:36:1]
shell_wall = 1.5; //[0.8:3:0.1]
face_thk = 2.5; //[1.2:5:0.1]

flange_W = 40; //[20:80:1]
flange_H = 16; //[8:32:1]
flange_thk = 2.5; //[1.2:6:0.1]

hole_d = 3.2; //[2:6.5:0.1]
hole_pitch = 33; //[20:60:1]

rear_cyl_d = 10; //[5:20:0.5]
rear_cyl_L = 12; //[6:30:1]

overlap = 1; //[0.5:2:0.1]
lip_inset = 0.8; //[0.4:2:0.1]
lip_thk = 0.8; //[0.4:2:0.1]

pin_cols = 5; //[3:9:1]
pin_rows = 2; //[1:3:1]
pin_d = 1; //[0.6:2:0.1]
pin_L = 3; //[1.5:8:0.5]
pin_pitch_x = 2.8; //[2:5:0.1]
pin_pitch_y = 2.3; //[1.5:4:0.1]

jackscrew_d = 5; //[3:8:0.1]
jackscrew_L = 6; //[3:15:0.5]

// D-shape controls (approximate D-sub outline)
d_flat_frac = 0.72;          // kept for compatibility (not used directly)
d_round_r_frac = 0.55;       // relative to shell_H/2
d_round_steps = 64;

// Helpers
function clamp(x,a,b) = x<a ? a : (x>b ? b : x);

// 2D D-profile (flat on LEFT, rounded on RIGHT)
module d_profile_2d(w, h) {
  r = clamp((h/2)*d_round_r_frac, 0.1, h/2);
  x_flat = (w/2) - r;
  x_flat = clamp(x_flat, 0.1, w/2 - 0.1);

  pts_arc = [
    for (i = [0:d_round_steps])
      let(a = 90 - i*180/d_round_steps)
      [x_flat + r*cos(a), r*sin(a)]
  ];

  polygon(points=concat(
    [[-w/2,  h/2], [x_flat,  h/2]],
    pts_arc,
    [[x_flat, -h/2], [-w/2, -h/2]]
  ));
}

// Base Shapes
module d_shell_outer() {
  linear_extrude(height=shell_D, center=true)
    d_profile_2d(shell_W, shell_H);
}

module d_shell_inner() {
  inner_w = shell_W - 2*shell_wall;
  inner_h = shell_H - 2*shell_wall;
  inner_d = shell_D - 2*shell_wall;

  linear_extrude(height=inner_d, center=true)
    d_profile_2d(inner_w, inner_h);
}

module mating_face_plate() {
  linear_extrude(height=face_thk, center=true)
    d_profile_2d(shell_W, shell_H);
}

// D-shaped flange
module mounting_flange_plate() {
  linear_extrude(height=flange_thk, center=true)
    d_profile_2d(flange_W, flange_H);
}

module mount_hole_cyl(h) {
  cylinder(r=hole_d/2, h=h, center=true);
}

module rear_strain_relief_cylinder() {
  cylinder(r=rear_cyl_d/2, h=rear_cyl_L, center=true);
}

module shell_lip_outer() {
  linear_extrude(height=lip_thk, center=true)
    d_profile_2d(shell_W, shell_H);
}

module shell_lip_inner() {
  linear_extrude(height=lip_thk + 2*overlap, center=true)
    d_profile_2d(shell_W - 2*lip_inset, shell_H - 2*lip_inset);
}

module pin_cyl() {
  cylinder(r=pin_d/2, h=pin_L, center=true);
}

module jackscrew_cyl() {
  cylinder(r=jackscrew_d/2, h=jackscrew_L, center=true);
}

// Operations
module d_shell_body() {
  difference() {
    d_shell_outer();
    d_shell_inner();
  }
}

module mounting_flange_with_holes() {
  // Put flange centered at the shell front plane, with overlap into shell
  // Shell front plane is at z = -shell_D/2
  z_flange = -shell_D/2 - flange_thk/2 + overlap;

  difference() {
    translate([0, 0, z_flange]) mounting_flange_plate();

    // Through-holes (ensure they fully cut flange)
    translate([-hole_pitch/2, 0, z_flange])
      mount_hole_cyl(flange_thk + 4*overlap);
    translate([ hole_pitch/2, 0, z_flange])
      mount_hole_cyl(flange_thk + 4*overlap);
  }
}

module shell_lip_ring() {
  // Face plate is in front of shell; lip is in front of face plate.
  z_face = -shell_D/2 - face_thk/2 + overlap;

  // Lip touches the front of the face plate with overlap
  // Face front plane: z_face - face_thk/2
  // Lip back plane:   z_lip + lip_thk/2
  // Set z_lip so: z_lip + lip_thk/2 = (z_face - face_thk/2) + overlap
  z_lip = (z_face - face_thk/2) - lip_thk/2 + overlap;

  difference() {
    translate([0, 0, z_lip]) shell_lip_outer();
    translate([0, 0, z_lip]) shell_lip_inner();
  }
}

module mating_face() {
  z_face = -shell_D/2 - face_thk/2 + overlap;
  union() {
    translate([0, 0, z_face]) mating_face_plate();
    shell_lip_ring();
  }
}

module pin_array() {
  // Pins protrude from the front of the face plate (front direction = -Z)
  z_face = -shell_D/2 - face_thk/2 + overlap;
  z_face_front = z_face - face_thk/2;

  // Pin back plane touches face front plane with overlap:
  // pin center z_pins so: z_pins + pin_L/2 = z_face_front + overlap
  z_pins = z_face_front - pin_L/2 + overlap;

  for (row = [0:pin_rows-1]) {
    for (col = [0:pin_cols-1]) {
      x_off = (row % 2 == 1) ? pin_pitch_x/2 : 0;
      translate([
        -(pin_cols-1)*pin_pitch_x/2 + col*pin_pitch_x + x_off,
        -(pin_rows-1)*pin_pitch_y/2 + row*pin_pitch_y,
        z_pins
      ]) pin_cyl();
    }
  }
}

module jackscrews() {
  // Jackscrews protrude forward from the flange (front direction = -Z)
  z_flange = -shell_D/2 - flange_thk/2 + overlap;
  z_flange_front = z_flange - flange_thk/2;

  // Jackscrew back plane touches flange front plane with overlap
  z_js = z_flange_front - jackscrew_L/2 + overlap;

  translate([-hole_pitch/2, 0, z_js]) jackscrew_cyl();
  translate([ hole_pitch/2, 0, z_js]) jackscrew_cyl();
}

// Mounting ears/flanges with screw holes (typical D-sub silhouette)
// IMPORTANT: holes must also cut through ears so they don't appear as separate solids.
module mounting_ears_with_holes() {
  ear_w = max(8, hole_d + 6);
  ear_h = max(10, flange_H * 0.75);
  ear_thk = flange_thk;

  z_flange = -shell_D/2 - flange_thk/2 + overlap;

  // Ears overlap the flange by 'overlap' so everything is one solid
  x_ear = flange_W/2 + ear_w/2 - overlap;

  difference() {
    union() {
      translate([ x_ear, 0, z_flange]) cube([ear_w, ear_h, ear_thk], center=true);
      translate([-x_ear, 0, z_flange]) cube([ear_w, ear_h, ear_thk], center=true);
    }
    // Extend holes to cut ears too
    translate([-hole_pitch/2, 0, z_flange])
      mount_hole_cyl(ear_thk + 4*overlap);
    translate([ hole_pitch/2, 0, z_flange])
      mount_hole_cyl(ear_thk + 4*overlap);
  }
}

module connector_body_union() {
  union() {
    // Main D-shaped shell
    d_shell_body();

    // Front mating face + lip (D-shaped)
    mating_face();

    // D-shaped flange + ears (recognizable D-sub outline)
    mounting_flange_with_holes();
    mounting_ears_with_holes();

    // Rear strain relief connected to shell back (+Z)
    translate([0, 0, shell_D/2 + rear_cyl_L/2 - overlap])
      rear_strain_relief_cylinder();
  }
}

module connector_complete() {
  // Pin carrier overlaps into the mating face so pins are supported and connected.
  carrier_w = min(shell_W - 2*shell_wall, (pin_cols-1)*pin_pitch_x + pin_pitch_x);
  carrier_h = min(shell_H - 2*shell_wall, (pin_rows-1)*pin_pitch_y + pin_pitch_y);
  carrier_thk = max(1.2, face_thk*0.6);

  z_face = -shell_D/2 - face_thk/2 + overlap;
  z_face_front = z_face - face_thk/2;

  // Carrier front plane touches face back plane with overlap:
  // face back plane: z_face + face_thk/2
  // carrier front plane: z_carrier - carrier_thk/2
  // set: z_carrier - carrier_thk/2 = (z_face + face_thk/2) - overlap
  z_carrier = (z_face + face_thk/2) - overlap + carrier_thk/2;

  union() {
    connector_body_union();

    translate([0, 0, z_carrier])
      cube([carrier_w, carrier_h, carrier_thk], center=true);

    pin_array();
    jackscrews();
  }
}

// Final Output (one connected solid, recognizable D-sub / "D connector")
connector_complete();