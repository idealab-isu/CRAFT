$fn = 64;

// Parameters
shell_W = 30; //[15:60:1]
shell_H = 12; //[6:24:1]
shell_D = 15; //[8:30:1]
shell_wall_t = 1.5; //[0.8:3:0.1]

flange_W = 40; //[20:80:1]
flange_H = 16; //[8:32:1]
flange_t = 2.5; //[1.2:6:0.1]

hole_d = 3.2; //[2:6:0.1]
hole_spacing = 33; //[16:66:1]

overlap = 1; //[0.5:2:0.1]

lip_t = 1; //[0.5:2:0.1]
lip_inset = 0.8; //[0.4:2:0.1]

pin_d = 1; //[0.6:2:0.1]
pin_len = 6; //[3:12:0.5]
pin_pitch_x = 2.8; //[2:5:0.1]
pin_pitch_y = 2.5; //[2:5:0.1]
pin_cols = 5; //[3:9:1]
pin_rows = 2; //[1:3:1]

strain_relief_r = 6; //[3:12:0.5]
strain_relief_len = 10; //[5:25:1]

post_od = 6; //[4:12:0.5]
post_id = 3.2; //[2:6:0.1]
post_h = 8; //[4:20:1]

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module d_profile_2d(w, h) {
  // D-sub style: left flat, right semicircle
  r = h/2;
  w_eff = max(w, h + 0.01);
  union() {
    // rectangle part (flat side on left)
    translate([-w_eff/2 + (w_eff - h)/2, 0])
      square([w_eff - h, h], center=true);
    // semicircle on right
    translate([w_eff/2 - r, 0])
      circle(r=r);
  }
}

module d_shell_outer() {
  linear_extrude(height=shell_D, center=true)
    d_profile_2d(shell_W, shell_H);
}

module d_shell_inner() {
  w_in = shell_W - 2*shell_wall_t;
  h_in = shell_H - 2*shell_wall_t;
  linear_extrude(height=max(0.01, shell_D - shell_wall_t), center=true)
    d_profile_2d(max(0.01, w_in), max(0.01, h_in));
}

module shell_lip_outer() {
  linear_extrude(height=lip_t, center=true)
    d_profile_2d(shell_W, shell_H);
}

module shell_lip_inner() {
  w_in = shell_W - 2*lip_inset;
  h_in = shell_H - 2*lip_inset;
  linear_extrude(height=lip_t + overlap*2, center=true)
    d_profile_2d(max(0.01, w_in), max(0.01, h_in));
}

module mounting_flange_solid() {
  cube([flange_W, flange_H, flange_t], center=true);
}

module mount_hole_cyl() {
  cylinder(r=hole_d/2, h=flange_t + overlap*2, center=true);
}

module pin_cyl() {
  cylinder(r=pin_d/2, h=pin_len, center=true);
}

module rear_strain_relief() {
  cylinder(r=strain_relief_r, h=strain_relief_len, center=true);
}

module screw_post_outer() {
  cylinder(r=post_od/2, h=post_h, center=true);
}

module screw_post_inner() {
  cylinder(r=post_id/2, h=post_h + overlap*2, center=true);
}

// ---------- Complete connector (ONE connected solid) ----------
module connector_complete() {

  // Derived placements (no arbitrary numbers)
  z_shell = 0;

  // Flange behind shell (negative Z), overlapping into shell
  z_flange = z_shell - shell_D/2 - flange_t/2 + overlap;

  // Lip on mating face (front, positive Z), overlapping into shell
  z_lip = z_shell + shell_D/2 - lip_t/2 + overlap;

  // Pins protrude out the front face, overlapping into shell
  z_pins = z_shell + shell_D/2 + pin_len/2 - overlap;

  // Strain relief protrudes out the back, overlapping into shell
  z_strain = z_shell - shell_D/2 - strain_relief_len/2 + overlap;

  // Screw posts extend behind flange, overlapping into flange
  z_posts = z_flange - flange_t/2 - post_h/2 + overlap;

  // Pin grid extents
  cols = pin_cols;
  rows = pin_rows;

  // Keep pins within the D opening
  x_max = shell_W/2 - shell_wall_t - pin_d;
  y_max = shell_H/2 - shell_wall_t - pin_d;

  union() {

    // Hollow metal shell (D-shaped)
    difference() {
      d_shell_outer();
      // inner cavity shifted slightly forward to keep back wall thickness
      translate([0, 0, shell_wall_t/2])
        d_shell_inner();
    }

    // Mounting flange with holes (connected to shell via overlap)
    translate([0, 0, z_flange])
      difference() {
        mounting_flange_solid();
        translate([-hole_spacing/2, 0, 0]) mount_hole_cyl();
        translate([ hole_spacing/2, 0, 0]) mount_hole_cyl();
      }

    // Mating lip (connected to shell via overlap)
    translate([0, 0, z_lip])
      difference() {
        shell_lip_outer();
        shell_lip_inner();
      }

    // Pins (connected to shell via overlap)
    for (ci = [0:cols-1]) {
      for (ri = [0:rows-1]) {
        x = (ci - (cols-1)/2) * pin_pitch_x;
        y = (ri - (rows-1)/2) * pin_pitch_y;
        x2 = clamp(x, -x_max, x_max);
        y2 = clamp(y, -y_max, y_max);
        translate([x2, y2, z_pins]) pin_cyl();
      }
    }

    // Rear strain relief (connected to shell via overlap)
    translate([0, 0, z_strain]) rear_strain_relief();

    // Screw posts (connected to flange via overlap)
    for (sx = [-hole_spacing/2, hole_spacing/2]) {
      translate([sx, 0, z_posts])
        difference() {
          screw_post_outer();
          screw_post_inner();
        }
    }
  }
}

// Render the complete connector
color("Silver") connector_complete();