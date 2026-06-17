$fn = 96;

// ---------------- Parameters ----------------
block_L = 40.0; //[20.0:80.0:0.5]  // X (overall)
block_W = 35.0; //[17.5:70.0:0.5]  // Y (overall)
block_H = 20.0; //[10.0:40.0:0.5]  // Z (overall)

shaft_d = 8.0; //[4.0:16.0:0.1]
bore_clearance = 0.2; //[0.0:0.6:0.05]
bore_d = shaft_d + bore_clearance; //[4.0:20.0:0.05]

// Make it a recognizable linear bearing block: LM8UU-style pocket along X
bearing_OD = 15.0;          // typical LM8UU OD
bearing_clearance = 0.3;    // housing clearance
bearing_bore_d = bearing_OD + bearing_clearance;
bearing_len = 24.0;         // typical LM8UU length
bearing_end_lip = 2.0;      // material left at each end (retaining lips)
bearing_pocket_len = min(block_L - 2*bearing_end_lip, bearing_len);

mount_hole_d = 4.5; //[2.5:8.0:0.1]
mount_hole_edge_offset_L = 7.0; //[3.5:14.0:0.5]
mount_hole_edge_offset_W = 7.0; //[3.5:14.0:0.5]

counterbore_d = 8.5; //[6.0:14.0:0.1]
counterbore_depth = 3.0; //[1.0:8.0:0.1]

grease_port_d = 3.0; //[1.5:6.0:0.1]
set_screw_d = 3.0; //[2.0:6.0:0.1]

edge_round_r = 1.0; //[0.0:3.0:0.1]
chamfer = 0.8; //[0.0:2.0:0.1]

eps = 0.2; //[0.05:1.0:0.05]
overlap = 1.2; // 1–2mm overlap for robust boolean connections

// ---------------- Helpers ----------------
module rounded_block(L, W, H, r) {
  r_eff = min(r, min(L, min(W, H))/2 - 0.01);
  if (r_eff <= 0)
    cube([L, W, H], center=true);
  else
    minkowski() {
      cube([L - 2*r_eff, W - 2*r_eff, H - 2*r_eff], center=true);
      sphere(r=r_eff);
    }
}

// Main block body (exact overall size)
module main_block_body() {
  rounded_block(block_L, block_W, block_H, edge_round_r);
}

// Through shaft bore (along X)
module shaft_bore_through() {
  rotate([0, 90, 0])
    cylinder(h=block_L + 2*eps, r=bore_d/2, center=true);
}

// Bearing pocket (LM8UU housing) along X, leaving lips at both ends
module bearing_pocket() {
  // Ensure pocket fits inside block
  pocket_len = max(0, min(bearing_pocket_len, block_L - 2*bearing_end_lip));
  rotate([0, 90, 0])
    cylinder(h=pocket_len + 2*eps, r=bearing_bore_d/2, center=true);
}

// Bore lead-in chamfers (conical lead-ins on both X faces)
module bore_lead_in_chamfers() {
  cham = min(chamfer, block_L/4);
  union() {
    // +X face
    translate([ block_L/2 - cham/2, 0, 0 ])
      rotate([0, 90, 0])
        cylinder(h=cham + 2*eps, r1=bore_d/2 + cham, r2=bore_d/2, center=true);

    // -X face
    translate([ -block_L/2 + cham/2, 0, 0 ])
      rotate([0, 90, 0])
        cylinder(h=cham + 2*eps, r1=bore_d/2, r2=bore_d/2 + cham, center=true);
  }
}

// Mounting holes (through Z)
module mounting_holes_4x() {
  x_pos = block_L/2 - mount_hole_edge_offset_L;
  y_pos = block_W/2 - mount_hole_edge_offset_W;

  for (sx = [-1, 1])
    for (sy = [-1, 1])
      translate([ sx*x_pos, sy*y_pos, 0 ])
        cylinder(h=block_H + 2*eps, r=mount_hole_d/2, center=true);
}

// Counterbores on TOP face only
module counterbores_top_only() {
  x_pos = block_L/2 - mount_hole_edge_offset_L;
  y_pos = block_W/2 - mount_hole_edge_offset_W;

  for (sx = [-1, 1])
    for (sy = [-1, 1])
      translate([ sx*x_pos, sy*y_pos, block_H/2 - counterbore_depth/2 ])
        cylinder(h=counterbore_depth + 2*eps, r=counterbore_d/2, center=true);
}

// Grease port from TOP face down to intersect bearing pocket/shaft bore
module grease_port_top() {
  // Start at top face and go deep enough to reach the bearing pocket region
  port_depth = block_H; // full depth ensures intersection
  translate([0, 0, block_H/2 - port_depth/2])
    cylinder(h=port_depth + 2*eps, r=grease_port_d/2, center=true);
}

// Retention set screw hole from FRONT face (along Y), intersects bearing pocket/shaft bore
module retention_set_screw_hole() {
  rotate([90, 0, 0])
    cylinder(h=block_W + 2*eps, r=set_screw_d/2, center=true);
}

// Add a simple clamp "ear" on top to make it read as a bearing carriage (single solid)
module top_clamp_boss() {
  // A shallow boss centered on top, overlapping into the main body
  boss_L = block_L * 0.70;
  boss_W = block_W * 0.55;
  boss_H = 6.0;

  // Place so it sits on top with overlap into the body
  translate([0, 0, block_H/2 + boss_H/2 - overlap])
    rounded_block(boss_L, boss_W, boss_H, edge_round_r);
}

// Clamp slit (visual/functional cue), cut from top down to near the bearing pocket
module clamp_slit_cut() {
  slit_w = 2.0;
  slit_L = block_L * 0.80;
  // Cut through the top boss and slightly into the main body
  slit_H = (6.0 + overlap) + (block_H * 0.35);

  translate([0, 0, block_H/2 + 6.0/2 - overlap])  // aligned with boss
    cube([slit_L, slit_w, slit_H + 2*eps], center=true);
}

// ---------------- Final bearing block ----------------
module bearing_block_complete() {
  difference() {
    union() {
      main_block_body();
      top_clamp_boss(); // connected via overlap
    }

    // Primary functional features: bearing pocket + through shaft bore
    bearing_pocket();
    shaft_bore_through();
    bore_lead_in_chamfers();

    // Mounting
    mounting_holes_4x();
    counterbores_top_only();

    // Service/retention
    grease_port_top();
    retention_set_screw_hole();

    // Clamp cue
    clamp_slit_cut();
  }
}

bearing_block_complete();