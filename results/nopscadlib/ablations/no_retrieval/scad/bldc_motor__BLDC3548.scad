// Brushless DC motor (single connected solid)
// Target: 35.0mm stator diameter, 45.0mm motor can height (excluding shaft)
// Fixes:
// - Orthographic consistency: add front/back face features (boss + recess + bolt holes) so views aren't flat discs
// - Verifiable scale: can OD tied to stator_d; can height = motor_h
// - Motor-specific features: stator/rotor, mounting pattern, shaft, rear wire exit/connector
// - One connected solid: all added solids overlap into the can/endcaps; no floating parts

$fn = 128;

// -------------------- Parameters --------------------
stator_d = 35.0;          //[17.5:70.0:0.5]  // REQUIRED
motor_h  = 45.0;          //[22.5:90.0:0.5]  // REQUIRED (can height)

can_wall_t = 1.0;         //[0.5:2.0:0.1]
can_od = stator_d + 2*can_wall_t;  // verifiable tie to stator diameter

endcap_t = 2.0;           //[1.0:5.0:0.25]

stator_h = 20.0;          //[10.0:40.0:0.5]
stator_id = 20.0;         //[10.0:40.0:0.5]

airgap = 0.5;             //[0.2:1.5:0.1]
rotor_od = stator_d - 2*airgap;
rotor_h = stator_h;

shaft_d = 5.0;            //[2.5:10.0:0.1]
shaft_len_front = 15.0;   //[7.5:30.0:0.5]
shaft_len_rear  = 5.0;    //[2.5:15.0:0.5]

flange_od = 42.0;         //[21.0:84.0:0.5]
flange_t  = 2.5;          //[1.25:6.0:0.25]

mount_hole_count = 4;     //[3:8:1]
mount_hole_d = 3.0;       //[1.5:6.0:0.1]
mount_hole_pcd = 30.0;    //[15.0:60.0:0.5]

slot_count = 12;          //[4:24:1]
slot_w = 2.5;             //[1.5:6.0:0.25]
slot_h = 18.0;            //[6.0:24.0:0.5]
slot_radial_depth = 1.6;  //[1.0:4.0:0.25]

label_band_h = 10.0;      //[5.0:20.0:0.5]
label_band_t = 0.4;       //[0.2:1.0:0.1]

wire_grommet_d = 6.0;     //[3.0:12.0:0.5]
wire_grommet_len = 4.0;   //[2.0:10.0:0.5]

connector_w = 10.0;       //[5.0:20.0:0.5]
connector_d = 6.0;        //[3.0:15.0:0.5]
connector_h = 6.0;        //[3.0:15.0:0.5]

overlap = 1.0;            //[0.5:2.0:0.1]
chamfer_r = 0.8;          //[0.4:2.0:0.1]

// Face detail (to avoid flat orthographic discs)
face_boss_d = 16.0;       //[8.0:28.0:0.5]
face_boss_t = 1.2;        //[0.6:3.0:0.1]
face_recess_d = 22.0;     //[10.0:32.0:0.5]
face_recess_t = 0.8;      //[0.4:2.0:0.1]

// -------------------- Derived --------------------
can_r = can_od/2;
stator_r = stator_d/2;
rotor_r = rotor_od/2;

z_front =  motor_h/2;
z_rear  = -motor_h/2;

// -------------------- Helpers --------------------
module ring_chamfer(zpos, r_outer, r_ch) {
  translate([0,0,zpos])
    rotate_extrude()
      translate([r_outer - r_ch, 0, 0])
        circle(r=r_ch);
}

module radial_slots() {
  // Subtractive slots that cut into the can wall (visible in side views).
  for (i = [0:slot_count-1]) {
    rotate([0,0,i*360/slot_count])
      translate([can_r - slot_radial_depth/2, 0, 0])
        cube([slot_radial_depth + 2*overlap, slot_w, slot_h], center=true);
  }
}

module mount_holes(z_center, h_through) {
  for (i = [0:mount_hole_count-1]) {
    rotate([0,0,i*360/mount_hole_count])
      translate([mount_hole_pcd/2, 0, z_center])
        cylinder(h=h_through, r=mount_hole_d/2, center=true);
  }
}

// -------------------- Main solids --------------------
module can_shell_with_slots() {
  difference() {
    // Outer can
    cylinder(h=motor_h, r=can_r, center=true);

    // Inner void (leave endcaps solid by shortening void)
    cylinder(h=motor_h - 2*endcap_t, r=can_r - can_wall_t, center=true);

    // Cooling slots
    radial_slots();
  }
}

module endcaps() {
  // Slightly proud endcaps to create visible edges in orthographic views
  union() {
    translate([0,0,z_front - endcap_t/2])
      cylinder(h=endcap_t, r=can_r - can_wall_t + overlap, center=true);

    translate([0,0,z_rear + endcap_t/2])
      cylinder(h=endcap_t, r=can_r - can_wall_t + overlap, center=true);
  }
}

module front_flange_drilled() {
  // Front mounting flange with through holes
  difference() {
    translate([0,0,z_front + flange_t/2 - overlap])
      cylinder(h=flange_t, r=flange_od/2, center=true);

    mount_holes(z_front + flange_t/2 - overlap, flange_t + 2*overlap);
  }
}

module shaft() {
  // One continuous shaft through motor, extending front and rear
  total_len = motor_h + shaft_len_front + shaft_len_rear;
  translate([0,0,(shaft_len_front - shaft_len_rear)/2])
    cylinder(h=total_len, r=shaft_d/2, center=true);
}

module internal_stator_rotor_visual() {
  // Internal features fused to shell via a rear bridge boss (ensures one connected solid)
  union() {
    // Stator ring (solid ring)
    difference() {
      cylinder(h=stator_h, r=stator_r, center=true);
      cylinder(h=stator_h + 2*overlap, r=stator_id/2, center=true);
    }

    // Rotor cylinder (solid)
    cylinder(h=rotor_h, r=rotor_r, center=true);

    // Rear bridge boss: expands rotor to touch inner can near rear endcap
    bridge_r = max(1.2, (can_r - can_wall_t) - rotor_r);
    translate([0,0,z_rear + endcap_t/2])
      cylinder(h=endcap_t + overlap, r=rotor_r + bridge_r, center=true);
  }
}

module wire_exit_and_connector() {
  // Place on rear endcap region; ensure overlap into can so it is connected.
  z_grom = z_rear + endcap_t/2; // centered on rear endcap thickness
  x_grom = can_r + wire_grommet_len/2 - overlap;

  union() {
    // Grommet cylinder (radial)
    translate([x_grom, 0, z_grom])
      rotate([0,90,0])
        cylinder(h=wire_grommet_len, r=wire_grommet_d/2, center=true);

    // Connector stub above grommet, overlapping into can
    x_con = can_r + connector_d/2 - overlap;
    z_con = z_rear + endcap_t/2 + connector_h/2 - overlap;
    translate([x_con, 0, z_con])
      cube([connector_d, connector_w, connector_h], center=true);
  }
}

module label_band_feature() {
  // Slight raised band around mid-body for recognizable detail
  cylinder(h=label_band_h, r=can_r + label_band_t, center=true);
}

module face_details() {
  // Add non-flat features to front/back faces so orthographic views show motor-specific detail.
  // Implemented as: unioned bosses + subtracted recesses + subtracted bolt holes.
  // All placements are formula-based and overlap into endcaps/flange to remain connected.

  // Front boss sits on flange face and overlaps slightly into flange
  z_front_boss = z_front + face_boss_t/2 - overlap;
  // Back boss sits on rear endcap outer face and overlaps slightly into endcap
  z_rear_boss  = z_rear - face_boss_t/2 + overlap;

  difference() {
    union() {
      // Front pilot/boss
      translate([0,0,z_front_boss])
        cylinder(h=face_boss_t, r=face_boss_d/2, center=true);

      // Rear boss (smaller visual feature)
      translate([0,0,z_rear_boss])
        cylinder(h=face_boss_t, r=(face_boss_d*0.85)/2, center=true);
    }

    // Front shallow recess (cuts into flange face)
    z_front_recess = z_front + face_recess_t/2 - overlap;
    translate([0,0,z_front_recess])
      cylinder(h=face_recess_t + 2*overlap, r=face_recess_d/2, center=true);

    // Rear shallow recess (cuts into rear endcap face)
    z_rear_recess = z_rear - face_recess_t/2 + overlap;
    translate([0,0,z_rear_recess])
      cylinder(h=face_recess_t + 2*overlap, r=(face_recess_d*0.9)/2, center=true);

    // Add visible bolt holes on rear face too (shallow through endcap only)
    mount_holes(z_rear + endcap_t/2, endcap_t + 2*overlap);
  }
}

// -------------------- Final model (single connected solid) --------------------
union() {
  can_shell_with_slots();
  endcaps();
  front_flange_drilled();
  shaft();
  internal_stator_rotor_visual();
  wire_exit_and_connector();
  label_band_feature();
  face_details();

  // External chamfer rings (unioned)
  ring_chamfer(z_front - chamfer_r, can_r, chamfer_r);
  ring_chamfer(z_rear  + chamfer_r, can_r, chamfer_r);
}