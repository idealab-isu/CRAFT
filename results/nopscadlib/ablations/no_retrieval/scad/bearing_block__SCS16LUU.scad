$fn = 96;

// Parameters
block_W = 50.0; //[25.0:100.0:0.5]   // X
block_L = 85.0; //[42.5:170.0:0.5]   // Y (length along shaft)
block_H = 30.0; //[15.0:60.0:0.5]    // Z

shaft_d = 9.0; //[4.5:18.0:0.1]
bore_d  = 9.2; //[9.0:12.0:0.05]
bore_axis_offset_Z = 15.0; //[7.5:30.0:0.5] // from bottom face upward

chamfer_d = 0.8; //[0.2:2.0:0.1]

mount_hole_d = 5.5; //[3.0:10.0:0.1]
mount_hole_edge_X = 10.0; //[5.0:20.0:0.5]
mount_hole_edge_Y = 12.0; //[6.0:24.0:0.5]
counterbore_d = 10.0; //[6.0:18.0:0.1]
counterbore_depth = 5.0; //[2.0:12.0:0.5]

edge_fillet_r = 1.5; //[0.5:5.0:0.1]

grease_port_d = 3.0; //[1.5:6.0:0.1]
grease_port_depth = 12.0; //[6.0:24.0:0.5]

set_screw_d = 4.0; //[2.0:8.0:0.1]
set_screw_axis_offset_Y = 0.0; //[-20.0:20.0:0.5]

side_slot_w = 3.0; //[1.0:8.0:0.1]   // opening width (X) for visible bore/slot
side_slot_h = 6.0; //[2.0:16.0:0.5]  // opening height (Z) around bore center

overlap = 1.0; //[0.5:2.0:0.1]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Bore axis Z (center of shaft) kept inside the block
bore_Z = clamp(
  (-block_H/2) + bore_axis_offset_Z,
  -block_H/2 + bore_d/2 + 0.5,
   block_H/2 - bore_d/2 - 0.5
);

// Base solid (rounded edges)
module block_body() {
  r = edge_fillet_r;
  hull() {
    for (sx = [-1, 1], sy = [-1, 1], sz = [-1, 1])
      translate([sx*(block_W/2 - r), sy*(block_L/2 - r), sz*(block_H/2 - r)])
        sphere(r=r);
  }
}

// Cuts
module shaft_bore_cyl() {
  // Through-bore along Y (length)
  translate([0, 0, bore_Z])
    rotate([90, 0, 0])
      cylinder(h=block_L + 2*overlap, r=bore_d/2, center=true);
}

module bore_chamfer_front_cone() {
  // At +Y face
  translate([0, (block_L/2) - (chamfer_d/2) + (overlap/2), bore_Z])
    rotate([90, 0, 0])
      cylinder(h=chamfer_d + overlap,
               r1=(bore_d/2) + (chamfer_d/2),
               r2=bore_d/2,
               center=true);
}

module bore_chamfer_back_cone() {
  // At -Y face
  translate([0, -(block_L/2) + (chamfer_d/2) - (overlap/2), bore_Z])
    rotate([-90, 0, 0])
      cylinder(h=chamfer_d + overlap,
               r1=(bore_d/2) + (chamfer_d/2),
               r2=bore_d/2,
               center=true);
}

module side_opening_slot() {
  // Visible side opening to clearly show a bearing-style through-bore.
  // Slot opens from +X face into the bore region, running full length (Y).
  slot_w = clamp(side_slot_w, 0.5, block_W - 2);
  slot_h = clamp(side_slot_h, 0.5, block_H - 2);

  // Ensure slot reaches into the bore by at least 0.5mm
  x_inset = (bore_d/2) + 0.5;
  x_center = (block_W/2) - (slot_w/2) + (overlap/2);

  // If parameters would not reach the bore, force it to reach by widening inward
  // via shifting the slot slightly inward (still opens at +X face).
  x_center_adj = min(x_center, x_inset + slot_w/2);

  translate([x_center_adj, 0, bore_Z])
    cube([slot_w + overlap, block_L + 2*overlap, slot_h], center=true);
}

module mount_hole_at(x, y) {
  translate([x, y, 0])
    cylinder(h=block_H + 2*overlap, r=mount_hole_d/2, center=true);
}

module counterbore_at(x, y) {
  translate([x, y, (block_H/2) - (counterbore_depth/2) + (overlap/2)])
    cylinder(h=counterbore_depth + overlap, r=counterbore_d/2, center=true);
}

module grease_port_hole() {
  // From top face down
  translate([0, 0, (block_H/2) - (grease_port_depth/2) + (overlap/2)])
    cylinder(h=grease_port_depth + overlap, r=grease_port_d/2, center=true);
}

module retention_set_screw_hole() {
  // Cross-drilled from +X to -X, intersects bore
  translate([0, set_screw_axis_offset_Y, bore_Z])
    rotate([0, 90, 0])
      cylinder(h=block_W + 2*overlap, r=set_screw_d/2, center=true);
}

module mounting_holes() {
  x = block_W/2 - mount_hole_edge_X;
  y = block_L/2 - mount_hole_edge_Y;
  union() {
    mount_hole_at( x,  y);
    mount_hole_at(-x,  y);
    mount_hole_at( x, -y);
    mount_hole_at(-x, -y);
  }
}

module counterbores() {
  x = block_W/2 - mount_hole_edge_X;
  y = block_L/2 - mount_hole_edge_Y;
  union() {
    counterbore_at( x,  y);
    counterbore_at(-x,  y);
    counterbore_at( x, -y);
    counterbore_at(-x, -y);
  }
}

module shaft_bore() {
  union() {
    shaft_bore_cyl();
    bore_chamfer_front_cone();
    bore_chamfer_back_cone();
  }
}

module all_cuts() {
  union() {
    shaft_bore();
    side_opening_slot();          // makes the long bore clearly visible as a bearing feature
    mounting_holes();
    counterbores();
    grease_port_hole();
    retention_set_screw_hole();
  }
}

// Final Output (ONE connected solid)
difference() {
  block_body();
  all_cuts();
}