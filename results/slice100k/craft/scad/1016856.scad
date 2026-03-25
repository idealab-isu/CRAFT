// Rounded-rectangle stepped plate/bracket with 3-row keyhole/dogbone slots,
// shallow corner recess rings, and mid-side edge notches.
// Bounding box: 40 x 40 x 16 mm

$fn = 128;

// ---------------- Parameters ----------------
bb_x = 40.0;
bb_y = 40.0;
bb_z = 16.0;

corner_r = 6.0;

thin_t  = 8.0;
thick_t = 16.0;

boss_len_x = 14.0;          // thicker end length along +X

// Slots: 3 rows x 2 cols (arranged in three rows)
slot_rows = 3;
slot_cols = 2;
slot_pitch_y = 10.5;        // tighter so 3 rows read clearly within 40mm
slot_pitch_x = 16.0;
slot_center_x = 0.0;
slot_center_y = 0.0;

slot_major_len = 12.0;      // overall slot length (Y)
slot_tail_d    = 5.0;       // small end diameter
slot_head_d    = 7.0;       // large end diameter
slot_neck_w    = 4.0;       // neck width

// Corner recess "outline rings" (shallow annular pockets)
recess_outer_d = 10.0;
recess_ring_w  = 1.2;       // ring thickness
recess_depth   = 0.6;
recess_offset_from_corner = 8.0;

// Edge notches at mid-sides
edge_notch_w = 4.0;
edge_notch_d = 1.5;
edge_notch_h = 2.0;

eps = 0.02;
eps_overlap = 0.6;

// ---------------- Helpers ----------------
module rr2d(w, h, r) {
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r), sy*(h/2 - r)]) circle(r=r);
  }
}

module plate_solid() {
  // One connected solid: thin full plate + thick boss on +X end
  union() {
    // thin full footprint
    linear_extrude(height=thin_t, center=true)
      rr2d(bb_x, bb_y, corner_r);

    // thick boss region (adds thickness above thin plate)
    translate([0, 0, (thin_t/2) + (thick_t - thin_t)/2 - eps_overlap/2])
      linear_extrude(height=(thick_t - thin_t) + eps_overlap, center=true)
        intersection() {
          rr2d(bb_x, bb_y, corner_r);
          translate([bb_x/2 - boss_len_x/2, 0])
            square([boss_len_x + eps_overlap, bb_y + 2*eps_overlap], center=true);
        }
  }
}

module keyhole_dogbone_2d(major_len, head_d, tail_d, neck_w) {
  // 2D profile centered at origin, oriented along Y
  neck_len = max(0.01, major_len - head_d/2 - tail_d/2);

  union() {
    // neck
    square([neck_w, neck_len], center=true);

    // head circle (+Y)
    translate([0, (major_len/2 - head_d/2)]) circle(d=head_d);

    // tail circle (-Y)
    translate([0, -(major_len/2 - tail_d/2)]) circle(d=tail_d);

    // dogbone reliefs at transitions (subtle waist)
    translate([0, (major_len/2 - head_d/2) - (head_d/2 - neck_w/2)])
      circle(d=neck_w);
    translate([0, -(major_len/2 - tail_d/2) + (tail_d/2 - neck_w/2)])
      circle(d=neck_w);
  }
}

module slots_cut() {
  // Through-cut slots across full thick_t
  linear_extrude(height=thick_t + 2*eps, center=true)
    union() {
      for (r = [0:slot_rows-1]) {
        row = r - (slot_rows-1)/2;
        for (c = [0:slot_cols-1]) {
          col = c - (slot_cols-1)/2;
          translate([slot_center_x + col*slot_pitch_x,
                     slot_center_y + row*slot_pitch_y])
            keyhole_dogbone_2d(slot_major_len, slot_head_d, slot_tail_d, slot_neck_w);
        }
      }
    }
}

module corner_recess_rings_cut() {
  // Shallow annular recesses on BOTH faces (top and bottom)
  recess_inner_d = max(0.1, recess_outer_d - 2*recess_ring_w);

  for (sx = [-1, 1], sy = [-1, 1]) {
    x = sx*(bb_x/2 - recess_offset_from_corner);
    y = sy*(bb_y/2 - recess_offset_from_corner);

    // top face ring
    translate([x, y, thick_t/2 - recess_depth/2 + eps])
      linear_extrude(height=recess_depth + 2*eps, center=true)
        difference() {
          circle(d=recess_outer_d);
          circle(d=recess_inner_d);
        }

    // bottom face ring (on thin face)
    translate([x, y, -thin_t/2 + recess_depth/2 - eps])
      linear_extrude(height=recess_depth + 2*eps, center=true)
        difference() {
          circle(d=recess_outer_d);
          circle(d=recess_inner_d);
        }
  }
}

module mid_side_notches_cut() {
  // Small edge notches at mid-sides, cut into the perimeter
  // Place them in the thin region so they show in side views.
  zc = -thin_t/2 + edge_notch_h/2;

  // +X and -X sides
  translate([ bb_x/2 - edge_notch_d/2 + eps, 0, zc])
    cube([edge_notch_d + 2*eps, edge_notch_w, edge_notch_h + 2*eps], center=true);
  translate([-bb_x/2 + edge_notch_d/2 - eps, 0, zc])
    cube([edge_notch_d + 2*eps, edge_notch_w, edge_notch_h + 2*eps], center=true);

  // +Y and -Y sides
  translate([0,  bb_y/2 - edge_notch_d/2 + eps, zc])
    cube([edge_notch_w, edge_notch_d + 2*eps, edge_notch_h + 2*eps], center=true);
  translate([0, -bb_y/2 + edge_notch_d/2 - eps, zc])
    cube([edge_notch_w, edge_notch_d + 2*eps, edge_notch_h + 2*eps], center=true);
}

// ---------------- Final ----------------
difference() {
  plate_solid();
  slots_cut();
  corner_recess_rings_cut();
  mid_side_notches_cut();
}