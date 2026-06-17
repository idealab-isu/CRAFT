// Lichuan -80M01330B style servo motor (single connected solid)
// Fixes vs prior: correct servo-like form factor with clear front flange + pilot + shaft,
// visible bolt pattern/counterbores, rear connector/boss layout, and side fins.
// All translate() values are dimension-derived (no arbitrary offsets). One connected solid.

$fn = 96;

// ---------- Parameters (mm) ----------
body_L = 120;   // motor length (Z)
body_W = 80;    // motor width  (X)
body_H = 80;    // motor height (Y)

flange_W = 90;
flange_H = 90;
flange_t = 6;

pilot_d = 50;
pilot_h = 2.5;

mount_hole_d = 6.6;
mount_hole_spacing_X = 70;
mount_hole_spacing_Y = 70;
mount_counterbore_d = 11;
mount_counterbore_h = 2.2;

shaft_d = 19;
shaft_L = 40;
shaft_shoulder_d = 22;
shaft_shoulder_L = 5;
shaft_flat_depth = 1.0;
shaft_flat_L = 25;

oil_seal_ring_od = 32;
oil_seal_ring_id = 22;
oil_seal_ring_t = 2;

rear_boss_W = 45;
rear_boss_H = 35;
rear_boss_L = 18;

cable_stub_d = 12;
cable_stub_L = 20;

rear_pin_d = 2;
rear_pin_L = 6;
rear_pin_spacing = 5;

corner_fillet_r = 3.5;

// Cooling fins
fin_t = 2.2;        // fin thickness along Z
fin_depth = 2.0;    // protrusion from side faces (X)
fin_pitch = 8;
fin_span = 0.78;    // fraction of body_L covered by fins

// Front face details
front_step_inset = 6;
front_step_t = 2.5;
front_ring_od = 62;
front_ring_id = 52;
front_ring_t = 1.8;

// Side connector block
conn_W = 22;        // along Y
conn_H = 14;        // along Z
conn_L = 18;        // along X (sticks out)
conn_offset_Y = 0.22; // fraction of body_H from center toward +Y

overlap = 1;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2) {
  minkowski() {
    cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=true);
    sphere(r=r);
  }
}

module oil_seal_ring() {
  difference() {
    cylinder(d=oil_seal_ring_od, h=oil_seal_ring_t, center=true);
    cylinder(d=oil_seal_ring_id, h=oil_seal_ring_t + 2*overlap, center=true);
  }
}

module shaft_with_flat() {
  difference() {
    cylinder(d=shaft_d, h=shaft_L, center=true);
    // Flat on +X side, near the tip (front)
    translate([shaft_d/2 - shaft_flat_depth/2, 0, shaft_L/2 - shaft_flat_L/2])
      cube([shaft_d, shaft_d, shaft_flat_L], center=true);
  }
}

// ---------- Main Parts ----------
module housing() {
  rounded_box([body_W, body_H, body_L], r=corner_fillet_r);
}

module cooling_fins() {
  fin_len = body_L * fin_span;
  n = max(1, floor(fin_len / fin_pitch));
  z0 = -fin_len/2 + fin_pitch/2;

  for (i=[0:n-1]) {
    zpos = z0 + i*fin_pitch;

    // +X fins
    translate([ body_W/2 + fin_depth/2 - overlap, 0, zpos ])
      cube([fin_depth, body_H*0.92, fin_t], center=true);

    // -X fins
    translate([ -body_W/2 - fin_depth/2 + overlap, 0, zpos ])
      cube([fin_depth, body_H*0.92, fin_t], center=true);
  }
}

module front_flange_with_features() {
  // Flange plate with bolt holes + counterbores + recessed step + front ring
  difference() {
    union() {
      // Main flange
      cube([flange_W, flange_H, flange_t], center=true);

      // Front step pad (on front face)
      translate([0,0, flange_t/2 + front_step_t/2 - overlap])
        cube([flange_W - 2*front_step_inset, flange_H - 2*front_step_inset, front_step_t], center=true);

      // Front ring around pilot (raised)
      translate([0,0, flange_t/2 + front_step_t + front_ring_t/2 - overlap])
        difference() {
          cylinder(d=front_ring_od, h=front_ring_t, center=true);
          cylinder(d=front_ring_id, h=front_ring_t + 2*overlap, center=true);
        }
    }

    // Through holes (go through entire flange stack)
    hole_stack_h = flange_t + front_step_t + front_ring_t + 6*overlap;
    for (sx=[-1,1], sy=[-1,1]) {
      translate([sx*mount_hole_spacing_X/2, sy*mount_hole_spacing_Y/2, 0])
        cylinder(d=mount_hole_d, h=hole_stack_h, center=true);
    }

    // Counterbores on the front side (within step region)
    for (sx=[-1,1], sy=[-1,1]) {
      translate([sx*mount_hole_spacing_X/2, sy*mount_hole_spacing_Y/2,
                 flange_t/2 + front_step_t/2]) // centered in step thickness
        cylinder(d=mount_counterbore_d, h=mount_counterbore_h, center=true);
    }
  }
}

module pilot_and_seal() {
  union() {
    // Pilot boss (front)
    cylinder(d=pilot_d, h=pilot_h, center=true);

    // Oil seal ring slightly behind pilot (still on front side)
    translate([0,0, -pilot_h/2 - oil_seal_ring_t/2 + overlap])
      oil_seal_ring();
  }
}

module rear_boss_and_connector() {
  union() {
    // Rear boss block
    cube([rear_boss_W, rear_boss_H, rear_boss_L], center=true);

    // Connector block on +X side of rear boss (connected)
    translate([
      rear_boss_W/2 + conn_L/2 - overlap,
      (conn_offset_Y*body_H),
      0
    ])
      rounded_box([conn_L, conn_W, conn_H], r=min(2, min(conn_L, min(conn_W, conn_H))/5));

    // Cable stub exiting connector (+X direction), connected
    translate([
      rear_boss_W/2 + conn_L - overlap + cable_stub_L/2 - overlap,
      (conn_offset_Y*body_H),
      0
    ])
      rotate([0,90,0]) cylinder(d=cable_stub_d, h=cable_stub_L, center=true);

    // Rear alignment pins on rear face (Z-), connected
    for (sx=[-1,1], sy=[-1,1]) {
      translate([sx*rear_pin_spacing, sy*rear_pin_spacing, -rear_boss_L/2 - rear_pin_L/2 + overlap])
        cylinder(d=rear_pin_d, h=rear_pin_L, center=true);
    }
  }
}

// ---------- Assembly ----------
module servo_motor() {
  union() {
    // Body + fins
    housing();
    cooling_fins();

    // Front flange at +Z end of body
    translate([0,0, body_L/2 + flange_t/2 - overlap])
      front_flange_with_features();

    // Pilot + seal in front of flange
    translate([0,0, body_L/2 + flange_t + pilot_h/2 - overlap])
      pilot_and_seal();

    // Shaft shoulder in front of flange
    translate([0,0, body_L/2 + flange_t + shaft_shoulder_L/2 - overlap])
      cylinder(d=shaft_shoulder_d, h=shaft_shoulder_L, center=true);

    // Main shaft in front of shoulder
    translate([0,0, body_L/2 + flange_t + shaft_shoulder_L + shaft_L/2 - overlap])
      shaft_with_flat();

    // Rear boss + connector at -Z end of body
    translate([0,0, -body_L/2 - rear_boss_L/2 + overlap])
      rear_boss_and_connector();
  }
}

// ---------- Output ----------
color([0.15, 0.2, 0.35]) servo_motor();