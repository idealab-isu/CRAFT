// Brushless DC motor (BLDC) - 9.0mm stator diameter, 8.0mm height
// One connected solid, no floating parts, no text.

// -------------------- Parameters --------------------
stator_diameter_mm = 9.0;   //[4.5:18.0:0.1]
stator_height_mm   = 8.0;   //[4.0:16.0:0.1]

connect_overlap_mm = 0.4;   //[0.2:1.5:0.05]
$fn = 128;

// -------------------- Derived --------------------
stator_r = stator_diameter_mm/2;
stator_h = stator_height_mm;

// Can / endcaps (kept within stator diameter & height)
can_wall_mm   = max(0.6, stator_diameter_mm*0.08);
endcap_th_mm  = max(0.8, stator_height_mm*0.12);
endcap_r      = stator_r - can_wall_mm*0.25;

// Internal rotor/stator representation (kept inside can)
rotor_gap_mm  = max(0.25, stator_diameter_mm*0.03);
rotor_r       = stator_r - can_wall_mm - rotor_gap_mm;

// Shaft/boss (external, but connected)
shaft_d_mm    = max(1.2, stator_diameter_mm*0.18);
shaft_r       = shaft_d_mm/2;
shaft_len_mm  = max(2.0, stator_height_mm*0.35);

boss_d_mm     = max(4.0, stator_diameter_mm*0.55);
boss_r        = boss_d_mm/2;
boss_h_mm     = max(1.2, stator_height_mm*0.18);

// Mount holes (cut through boss only)
mount_hole_d_mm    = max(1.0, stator_diameter_mm*0.12);
mount_hole_r       = mount_hole_d_mm/2;
mount_hole_pitch_r = min(stator_r*0.62, boss_r - mount_hole_r - 0.4);

// Wires (connected to can)
wire_d_mm     = max(0.6, stator_diameter_mm*0.08);
wire_r        = wire_d_mm/2;
wire_len_mm   = max(4.0, stator_diameter_mm*0.55);
wire_exit_z_mm = -stator_h/2 + endcap_th_mm*0.55;

// Stator teeth (representative, connected to an inner stator ring)
stator_tooth_count = 9;
tooth_w_mm         = max(0.7, stator_diameter_mm*0.10);
tooth_len_mm       = max(0.9, stator_diameter_mm*0.12);
tooth_h_mm         = max(0.1, stator_h - 2*endcap_th_mm);
tooth_overlap_mm   = 0.35;

// Inner stator ring to make teeth clearly part of a stator structure
stator_ring_th_mm  = max(0.7, stator_diameter_mm*0.10);
stator_ring_r_out  = rotor_r - max(0.25, rotor_gap_mm*0.6);
stator_ring_r_in   = max(0.6, stator_ring_r_out - stator_ring_th_mm);

// -------------------- Modules --------------------
module motor_can() {
  // Outer can with endcap lips (all connected)
  union() {
    // Main can: EXACT stator diameter & height
    cylinder(r=stator_r, h=stator_h, center=true);

    // Top endcap lip (slight step)
    translate([0,0, stator_h/2 - endcap_th_mm/2])
      cylinder(r=endcap_r, h=endcap_th_mm + connect_overlap_mm, center=true);

    // Bottom endcap lip (slight step)
    translate([0,0,-stator_h/2 + endcap_th_mm/2])
      cylinder(r=endcap_r, h=endcap_th_mm + connect_overlap_mm, center=true);
  }
}

module rotor_and_shaft() {
  // Rotor core + boss + shaft (all connected to can via overlap)
  union() {
    // Rotor core (internal representation)
    cylinder(r=rotor_r, h=stator_h - 2*endcap_th_mm + connect_overlap_mm, center=true);

    // Front mounting boss (top side), overlaps into can
    translate([0,0, stator_h/2 + boss_h_mm/2 - connect_overlap_mm])
      cylinder(r=boss_r, h=boss_h_mm, center=true);

    // Shaft from boss (connected)
    translate([0,0, stator_h/2 + boss_h_mm - connect_overlap_mm + shaft_len_mm/2])
      cylinder(r=shaft_r, h=shaft_len_mm, center=true);
  }
}

module stator_core_and_teeth() {
  // A clear stator structure: inner ring + radial teeth pointing inward toward rotor center.
  // Everything is connected (teeth overlap into ring).
  union() {
    // Stator ring (annulus)
    difference() {
      cylinder(r=stator_ring_r_out, h=tooth_h_mm, center=true);
      cylinder(r=stator_ring_r_in,  h=tooth_h_mm + 2*connect_overlap_mm, center=true);
    }

    // Teeth: start at ring inner edge and protrude inward
    // Place tooth center at radius = stator_ring_r_in - tooth_len/2 + overlap
    for (i = [0:stator_tooth_count-1]) {
      rotate([0,0, i*360/stator_tooth_count])
        translate([stator_ring_r_in - tooth_len_mm/2 + tooth_overlap_mm, 0, 0])
          cube([tooth_len_mm, tooth_w_mm, tooth_h_mm], center=true);
    }
  }
}

module mounting_holes_cut() {
  // Two mounting holes through the front boss only (cutouts)
  for (a = [0, 180]) {
    rotate([0,0,a])
      translate([mount_hole_pitch_r, 0, stator_h/2 + boss_h_mm/2 - connect_overlap_mm])
        cylinder(r=mount_hole_r, h=boss_h_mm + 2*connect_overlap_mm, center=true);
  }
}

module wire_leads() {
  // Three wire leads exiting from the side near the bottom endcap.
  // Connected by overlapping into the can wall.
  // Ensure the inner end of each wire penetrates the can by connect_overlap_mm.
  wire_center_r = stator_r - wire_r + connect_overlap_mm; // pushes into can
  for (a = [210, 240, 270]) {
    rotate([0,0,a])
      translate([wire_center_r, 0, wire_exit_z_mm])
        rotate([0,90,0])
          cylinder(r=wire_r, h=wire_len_mm, center=true);
  }
}

module BLDC_motor() {
  // One connected solid: union of features, with mounting holes subtracted.
  difference() {
    union() {
      motor_can();
      rotor_and_shaft();
      stator_core_and_teeth();
      wire_leads();
    }
    mounting_holes_cut();
  }
}

BLDC_motor();