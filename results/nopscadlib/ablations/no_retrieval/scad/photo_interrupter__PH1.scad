// Photo interrupter (U-slot) - fixed: visible U-shaped fork/slot, connected geometry, no floating parts

$fn = 64;

// Parameters
body_L = 18; //[9:36:1]   // X
body_W = 6;  //[3:12:1]   // Y
body_H = 12; //[6:24:1]   // Z
wall_t = 1.5; //[0.8:3:0.1]

slot_W = 3.2; //[1.6:6.4:0.1]          // slot opening width (X)
slot_depth = 8; //[4:16:1]              // slot depth from TOP (Z)

pin_count = 4; //[2:8:1]
pin_pitch = 2.54; //[1.27:5.08:0.01]
pin_W = 0.5; //[0.25:1:0.05]
pin_D = 0.5; //[0.25:1:0.05]
pin_L = 5; //[2.5:10:0.5]
pin_standoff = 1; //[0.5:2:0.1]

ear_L = 4; //[2:8:0.5]
ear_W = 2.5; //[1.2:5:0.1]
ear_t = 2; //[1:4:0.1]
mount_hole_d = 2.2; //[1.1:4.4:0.1]
mount_hole_spacing = 12; //[6:24:1]

overlap = 1; //[0.5:2:0.1]
chamfer_size = 0.6; //[0.3:1.2:0.1]

key_notch_W = 1.2; //[0.6:2.4:0.1]
key_notch_D = 1.2; //[0.6:2.4:0.1]
key_notch_H = 2; //[1:4:0.1]

lens_r = 0.8; //[0.4:1.6:0.1]
lens_depth = 0.6; //[0.3:1.2:0.1]

pin_tip_taper_L = 1.2; //[0.6:2.4:0.1]

// Derived / safety clamps
slot_W_eff = min(slot_W, body_L - 2*wall_t - 0.2);
slot_depth_eff = min(slot_depth, body_H - wall_t - 0.2);

// Ensure there is material on both sides of the slot (fork arms)
arm_min = 1.2;
arm_W = max((body_L - slot_W_eff)/2, arm_min);
slot_W_eff2 = min(slot_W_eff, body_L - 2*arm_min);

// Recompute with enforced arms
arm_W2 = (body_L - slot_W_eff2)/2;

// Helpers
module chamfer_cut_x() {
  cube([body_L + 2*overlap, chamfer_size, chamfer_size], center=true);
}

module mount_hole_cut() {
  cylinder(r=mount_hole_d/2, h=ear_t + 2*overlap, center=true);
}

module lead_pin() {
  cube([pin_W, pin_D, pin_L + pin_standoff], center=true);
}

module pin_tip_taper() {
  cylinder(h=pin_tip_taper_L, r1=pin_W/2, r2=0, center=true);
}

module internal_lens() {
  rotate([0, 90, 0])
    cylinder(r=lens_r, h=lens_depth + 2*overlap, center=true);
}

module keying_notch_cut() {
  cube([key_notch_W, key_notch_D, key_notch_H], center=true);
}

// Main housing with a real U-slot (open from TOP down)
module u_shaped_housing() {
  difference() {
    // Outer body
    cube([body_L, body_W, body_H], center=true);

    // Slot cut: spans full Y (slightly beyond), starts at TOP and goes down slot_depth
    // Center Z = top - slot_depth/2
    translate([0, 0, body_H/2 - slot_depth_eff/2])
      cube([slot_W_eff2, body_W + 2*overlap, slot_depth_eff + 2*overlap], center=true);
  }
}

// Add small "lens" bumps on inner faces of the fork arms (inside the slot)
module lenses() {
  // Place within the slot region, on inner faces of arms
  lens_z = body_H/2 - slot_depth_eff*0.55; // inside the slot depth
  lens_x_left  = -slot_W_eff2/2 - lens_depth/2 + overlap; // protrude from left inner face into slot
  lens_x_right =  slot_W_eff2/2 + lens_depth/2 - overlap; // protrude from right inner face into slot

  translate([lens_x_left, 0, lens_z])  internal_lens();
  translate([lens_x_right, 0, lens_z]) internal_lens();
}

// Mounting ears attached to bottom (overlap into body for connectivity)
module mounting_ears() {
  ear_z = -body_H/2 + ear_t/2 - overlap;

  translate([-mount_hole_spacing/2, 0, ear_z])
    cube([ear_L, ear_W, ear_t], center=true);

  translate([ mount_hole_spacing/2, 0, ear_z])
    cube([ear_L, ear_W, ear_t], center=true);
}

// Housing with holes, notch, chamfers
module housing_detail() {
  difference() {
    // Start with connected union
    union() {
      u_shaped_housing();
      lenses();
      mounting_ears();
    }

    // Mount holes through ears
    ear_z = -body_H/2 + ear_t/2 - overlap;
    translate([-mount_hole_spacing/2, 0, ear_z]) mount_hole_cut();
    translate([ mount_hole_spacing/2, 0, ear_z]) mount_hole_cut();

    // Keying notch on one bottom-front corner (kept small; does not disconnect)
    translate([
      -body_L/2 + key_notch_W/2,
       body_W/2 - key_notch_D/2,
      -body_H/2 + wall_t + key_notch_H/2
    ])
      keying_notch_cut();

    // Top edge chamfers (front/back)
    translate([0,  body_W/2 - chamfer_size/2, body_H/2 - chamfer_size/2])
      rotate([45, 0, 0]) chamfer_cut_x();

    translate([0, -body_W/2 + chamfer_size/2, body_H/2 - chamfer_size/2])
      rotate([-45, 0, 0]) chamfer_cut_x();
  }
}

// Pins: overlap into body so the final model is ONE connected solid
module lead_pins() {
  union() {
    pin_total = pin_L + pin_standoff;

    // Put pin top slightly inside the body bottom for guaranteed connection
    // Pin center Z = bottom - pin_total/2 + overlap
    pin_z = -body_H/2 - pin_total/2 + overlap;

    for (i = [0:pin_count-1]) {
      x = (i - (pin_count-1)/2) * pin_pitch;

      translate([x, 0, pin_z]) lead_pin();

      // Taper at very bottom
      tip_z = (-body_H/2 - pin_total + pin_tip_taper_L/2) + overlap;
      translate([x, 0, tip_z]) pin_tip_taper();
    }
  }
}

// Final (ONE connected solid)
union() {
  housing_detail();
  lead_pins();
}