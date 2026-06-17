$fn = 128;

// =====================
// Target: BLDC motor
// Stator: 17.75mm OD, 14.5mm height (explicitly modeled)
// One connected solid (union of all parts; only subtract shaft bore + holes)
// =====================

// -------- Parameters (mm) --------
stator_od = 17.75;
stator_h  = 14.5;

stator_id = 10;                 // stator bore (for rotor/shaft clearance)
tooth_count = 12;
tooth_radial = 2.2;             // tooth protrusion from stator ID outward
slot_width = 1.2;

housing_od = 20;
housing_h  = 16;
housing_wall = 0.6;

endcap_thk = 1.2;
endcap_lip = 0.6;

shaft_bore_d = 3;               // through-bore (subtracted)
shaft_d = 2.5;                  // visible shaft (solid), slightly smaller than bore
shaft_len_front = 10;
shaft_len_back  = 2;

bearing_seat_d = 6;
bearing_seat_depth = 0.8;

mount_hole_d = 2;
mount_hole_count = 4;
mount_hole_pcd = 14;

vent_hole_d = 2;
vent_hole_count = 6;
vent_band_z = 0;

rotor_ring_thk = 1.2;
rotor_ring_h = 12;

wire_lead_d = 1.2;
wire_lead_len = 10;

clearance = 0.25;
overlap = 0.8;

// Derived
housing_id = housing_od - 2*housing_wall;

stator_r = stator_od/2;
housing_r = housing_od/2;
housing_ir = housing_id/2;

// Z locations (centered motor)
z_top_endcap_c =  housing_h/2 - endcap_thk/2 + overlap;   // slight overlap into can
z_bot_endcap_c = -housing_h/2 + endcap_thk/2 - overlap;

z_top_endcap_outer_face = housing_h/2 + endcap_thk/2;     // outside face
z_bot_endcap_outer_face = -housing_h/2 - endcap_thk/2;

// Ensure stator is INSIDE can and CONNECTS to endcaps (no floating):
// Place stator so its top/bottom slightly overlap the inner faces of endcaps.
z_stator_c = 0;
stator_top = z_stator_c + stator_h/2;
stator_bot = z_stator_c - stator_h/2;

top_endcap_inner_face = z_top_endcap_c - endcap_thk/2;    // face toward interior
bot_endcap_inner_face = z_bot_endcap_c + endcap_thk/2;

stator_shift_needed =
    (stator_top > top_endcap_inner_face - overlap ? (top_endcap_inner_face - overlap - stator_top) : 0) +
    (stator_bot < bot_endcap_inner_face + overlap ? (bot_endcap_inner_face + overlap - stator_bot) : 0);

z_stator_c_fixed = z_stator_c + stator_shift_needed;

// -------- Base shapes --------
module bs_housing_outer() { cylinder(h=housing_h, r=housing_r, center=true); }
module bs_housing_inner_void() { cylinder(h=housing_h + 2*overlap, r=housing_ir, center=true); }

module bs_stator_outer() { cylinder(h=stator_h, r=stator_r, center=true); }
module bs_stator_inner_void() { cylinder(h=stator_h + 2*overlap, r=stator_id/2, center=true); }

module bs_tooth_block() {
  // Teeth protrude outward from stator ID and overlap into core
  translate([stator_id/2 + tooth_radial/2 - overlap, 0, 0])
    cube([tooth_radial, slot_width, stator_h], center=true);
}

module bs_endcap_disk() { cylinder(h=endcap_thk, r=housing_r, center=true); }
module bs_endcap_lip()  { cylinder(h=endcap_thk, r=housing_ir + endcap_lip, center=true); }

module bs_mount_hole() {
  translate([mount_hole_pcd/2, 0, 0])
    cylinder(h=endcap_thk + 4*overlap, r=mount_hole_d/2, center=true);
}

module bs_bearing_seat() {
  cylinder(h=bearing_seat_depth + 2*overlap, r=bearing_seat_d/2, center=true);
}

module bs_shaft_bore() {
  cylinder(h=housing_h + 2*endcap_thk + shaft_len_front + shaft_len_back + 8*overlap,
           r=shaft_bore_d/2, center=true);
}

module bs_rotor_ring_outer() {
  // Rotor bell/magnet ring just inside housing, around stator OD
  cylinder(h=rotor_ring_h, r=stator_r + clearance + rotor_ring_thk, center=true);
}
module bs_rotor_ring_inner() {
  cylinder(h=rotor_ring_h + 2*overlap, r=stator_r + clearance, center=true);
}

module bs_vent_hole() {
  // Radial holes through can wall
  translate([housing_r - housing_wall/2, 0, vent_band_z])
    rotate([0, 90, 0])
      cylinder(h=housing_wall*4 + 2*overlap, r=vent_hole_d/2, center=true);
}

module bs_wire_lead() {
  // Wires exit from side near bottom endcap; ensure they intersect housing
  translate([housing_r + wire_lead_len/2 - overlap, 0,
             z_bot_endcap_c + endcap_thk/2 + wire_lead_d])
    rotate([0, 90, 0])
      cylinder(h=wire_lead_len, r=wire_lead_d/2, center=true);
}

module bs_shaft_solid() {
  // Visible shaft protruding from top endcap (front) and a small stub on back
  union() {
    translate([0, 0, z_top_endcap_outer_face + shaft_len_front/2 - overlap])
      cylinder(h=shaft_len_front, r=shaft_d/2, center=true);
    translate([0, 0, z_bot_endcap_outer_face - shaft_len_back/2 + overlap])
      cylinder(h=shaft_len_back, r=shaft_d/2, center=true);
  }
}

// -------- Operations --------
module op_housing_can_shell() {
  difference() {
    bs_housing_outer();
    bs_housing_inner_void();
  }
}

module op_stator_core_ring() {
  difference() {
    bs_stator_outer();
    bs_stator_inner_void();
  }
}

module op_stator_with_teeth() {
  translate([0, 0, z_stator_c_fixed])
    union() {
      op_stator_core_ring();
      for (i = [0:tooth_count-1])
        rotate([0, 0, i*360/tooth_count])
          bs_tooth_block();
    }
}

module op_endcap_lip_union() {
  union() {
    bs_endcap_disk();
    bs_endcap_lip();
  }
}

module op_endcap_top() {
  translate([0, 0, z_top_endcap_c])
    op_endcap_lip_union();
}

module op_endcap_bottom() {
  translate([0, 0, z_bot_endcap_c])
    op_endcap_lip_union();
}

module op_endcap_top_with_features() {
  translate([0,0,0])
  difference() {
    op_endcap_top();
    // mount holes
    for (i = [0:mount_hole_count-1])
      rotate([0, 0, i*360/mount_hole_count])
        translate([0, 0, z_top_endcap_c])
          bs_mount_hole();
    // bearing seat pocket
    translate([0, 0, z_top_endcap_c])
      bs_bearing_seat();
  }
}

module op_endcap_bottom_with_features() {
  translate([0,0,0])
  difference() {
    op_endcap_bottom();
    // mount holes
    for (i = [0:mount_hole_count-1])
      rotate([0, 0, i*360/mount_hole_count])
        translate([0, 0, z_bot_endcap_c])
          bs_mount_hole();
    // bearing seat pocket
    translate([0, 0, z_bot_endcap_c])
      bs_bearing_seat();
  }
}

module op_rotor_magnet_ring() {
  // Rotor bell/magnet ring around stator; centered to overlap endcaps slightly
  difference() {
    bs_rotor_ring_outer();
    bs_rotor_ring_inner();
  }
}

module op_housing_with_vents() {
  difference() {
    op_housing_can_shell();
    for (i = [0:vent_hole_count-1])
      rotate([0, 0, i*360/vent_hole_count])
        bs_vent_hole();
  }
}

module op_motor_union_prebore() {
  union() {
    // Can + endcaps (connected via overlap)
    op_housing_with_vents();
    op_endcap_top_with_features();
    op_endcap_bottom_with_features();

    // Stator inside (now guaranteed to overlap endcaps slightly)
    op_stator_with_teeth();

    // Rotor ring (bell/magnets) around stator, inside can
    op_rotor_magnet_ring();

    // Shaft (solid)
    bs_shaft_solid();

    // Three wire leads (connected to housing)
    bs_wire_lead();
    rotate([0, 0, 120]) bs_wire_lead();
    rotate([0, 0, 240]) bs_wire_lead();
  }
}

module op_motor_final() {
  // Subtract only the through shaft bore (keeps one connected solid)
  difference() {
    op_motor_union_prebore();
    bs_shaft_bore();
  }
}

// -------- Final Output --------
op_motor_final();