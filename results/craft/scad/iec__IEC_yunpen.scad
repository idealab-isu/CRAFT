$fn = 96;

// Target panel cutout (opening): 40.0mm x 29.0mm
cutout_w = 40.0;
cutout_h = 29.0;

// Keep as ONE connected solid (include a panel slab that intersects the module)
panel_t = 2.0;

// Helpers
overlap = 0.8;
fit_clearance = 0.4;

// Front flange / bezel (typical IEC inlet flange)
flange_w = 50.0;
flange_h = 35.0;
flange_t = 3.0;

// Through-panel body (snap-in/through section)
body_w = cutout_w - 2*fit_clearance;
body_h = cutout_h - 2*fit_clearance;
body_d = 18.0;

// Rear filter housing (can)
can_w = 52.0;
can_h = 38.0;
can_d = 28.0;

// Small neck between body and can (adds recognizable step + guarantees connection)
neck_w = min(body_w, can_w) - 6.0;
neck_h = min(body_h, can_h) - 6.0;
neck_d = 6.0;

// Mounting bosses (visual; keep solid)
boss_d = 7.0;
boss_h = flange_t + 1.0;
screw_spacing_x = 40.0;
screw_spacing_y = 25.0;

// IEC C14 inlet opening + recess
c14_open_w = 27.5;
c14_open_h = 20.0;
c14_recess_d = 8.0;

// C14 pin cavity (rear of inlet)
pin_cav_w = 18.0;
pin_cav_h = 12.0;
pin_cav_d = 10.0;

// Pin "blades" (solid features inside cavity so front/back views show pin geometry)
blade_w = 6.3;
blade_t = 1.2;
blade_len = 6.0;
blade_pitch_x = 14.0;
blade_pitch_y = 6.0;

// Rear spade terminals (3)
spade_w = 6.3;
spade_t = 0.8;
spade_len = 12.0;
spade_pitch_x = 14.0;
spade_pitch_y = 6.0;

// 2D rounded rectangle
module rr2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
  }
}

// 3D rounded rectangle prism
module rr3d(w, h, r, d, center=true) {
  linear_extrude(height=d, center=center) rr2d(w, h, r);
}

module iec_filtered_inlet() {

  // Z layout: +Z = front, -Z = rear
  flange_center_z = 0;
  flange_front_z  = flange_center_z + flange_t/2;
  flange_back_z   = flange_center_z - flange_t/2;

  // Body sits behind flange and overlaps slightly into it
  body_center_z = flange_back_z - body_d/2 + overlap;

  // Neck sits behind body and overlaps into both
  body_back_z = body_center_z - body_d/2;
  neck_center_z = body_back_z - neck_d/2 + overlap;

  // Can sits behind neck and overlaps into it
  neck_back_z = neck_center_z - neck_d/2;
  can_center_z = neck_back_z - can_d/2 + overlap;

  // Panel slab intersects the body (keeps one connected solid)
  panel_center_z = flange_back_z - panel_t/2 + overlap;

  union() {

    // Main solid with subtractions for inlet opening/cavity
    difference() {
      union() {
        // Flange (slightly rounded edges for a more realistic bezel)
        translate([0, 0, flange_center_z])
          rr3d(flange_w, flange_h, 2.0, flange_t, center=true);

        // Through-panel body (rounded rectangle)
        translate([0, 0, body_center_z])
          rr3d(body_w, body_h, 2.0, body_d, center=true);

        // Neck step (rounded rectangle)
        translate([0, 0, neck_center_z])
          rr3d(neck_w, neck_h, 2.0, neck_d, center=true);

        // Rear filter can (boxy housing)
        translate([0, 0, can_center_z])
          rr3d(can_w, can_h, 2.0, can_d, center=true);

        // Mounting bosses on flange
        for (x = [-screw_spacing_x/2, screw_spacing_x/2])
          for (y = [-screw_spacing_y/2, screw_spacing_y/2])
            translate([x, y, flange_center_z])
              cylinder(d=boss_d, h=boss_h, center=true);
      }

      // C14 opening through flange + into body (visible opening)
      // Make it go slightly past flange thickness so it is clearly open from the front.
      c14_cut_d = flange_t + c14_recess_d + overlap;
      c14_cut_center_z = flange_front_z - c14_cut_d/2 + overlap/2;
      translate([0, 0, c14_cut_center_z])
        rr3d(c14_open_w, c14_open_h, 2.0, c14_cut_d, center=true);

      // Pin cavity deeper into body (behind the opening)
      // Starts behind the recess and extends rearward.
      c14_recess_back_z = flange_front_z - (flange_t + c14_recess_d);
      pin_cav_center_z = c14_recess_back_z - pin_cav_d/2 - 0.5;
      translate([0, 0, pin_cav_center_z])
        rr3d(pin_cav_w, pin_cav_h, 1.5, pin_cav_d + overlap, center=true);

      // Key notch at top of C14 opening (subtle, recognizable)
      notch_w = 10.0;
      notch_h = 3.0;
      notch_d = flange_t + 2.0;
      notch_center_z = flange_front_z - notch_d/2 + overlap/2;
      translate([0, c14_open_h/2 - notch_h/2 - 1.0, notch_center_z])
        cube([notch_w, notch_h, notch_d + overlap], center=true);
    }

    // Pin blades (solid) inside the pin cavity so back view shows pin features
    // Place them near the rear of the pin cavity, but still inside it.
    pin_cav_rear_z = pin_cav_center_z - pin_cav_d/2;
    blade_center_z = pin_cav_rear_z + blade_len/2 + 0.6; // inside cavity
    translate([0, 0, 0]) {
      // Earth (top/center)
      translate([0, blade_pitch_y, blade_center_z])
        cube([blade_w, blade_t, blade_len], center=true);

      // Live/Neutral (bottom left/right)
      translate([-blade_pitch_x/2, -blade_pitch_y, blade_center_z])
        cube([blade_w, blade_t, blade_len], center=true);

      translate([ blade_pitch_x/2, -blade_pitch_y, blade_center_z])
        cube([blade_w, blade_t, blade_len], center=true);
    }

    // Rear spade terminals (solid protrusions) attached to rear face of can
    can_rear_z = can_center_z - can_d/2;
    spade_center_z = can_rear_z - spade_len/2 + overlap;

    translate([0, spade_pitch_y, spade_center_z])
      cube([spade_w, spade_t, spade_len], center=true);

    translate([-spade_pitch_x/2, -spade_pitch_y, spade_center_z])
      cube([spade_w, spade_t, spade_len], center=true);

    translate([ spade_pitch_x/2, -spade_pitch_y, spade_center_z])
      cube([spade_w, spade_t, spade_len], center=true);

    // Panel reference slab (intersecting the body so the whole model is one connected solid)
    translate([0, 0, panel_center_z])
      cube([cutout_w, cutout_h, panel_t], center=true);
  }
}

iec_filtered_inlet();