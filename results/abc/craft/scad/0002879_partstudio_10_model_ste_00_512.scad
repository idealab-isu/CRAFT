// Dimension-calibrated (target: 0.32 x 0.06 x 0.36 mm)
scale([0.429645, 5.283386, 1.101695])
{
// Curved C-like bracket/clip with two concentric ribs and a long tapered slot
// One connected solid, arc-shaped body, thicker end block + tab, tapered thin end
// Bounding box target: ~0.3 x 0.1 x 0.4 mm (X x Y x Z), elongated along Z

$fn = 128;

// ---------------- Parameters (mm) ----------------
bbox_x = 0.30;
bbox_y = 0.10;
bbox_z = 0.40;

// Arc in XZ plane, extruded along Y
arc_outer_R = 0.155;
arc_inner_R = 0.105;
arc_angle_deg = 210;

part_thickness_y = 0.06;
rib_thickness_radial = 0.020;

// Slot (tapered along arc)
slot_width_start = 0.020;   // wider near thick end
slot_width_end   = 0.010;   // narrower near thin end

// End features
end_block_len = 0.055;      // tangential length
end_block_height_z = 0.085; // radial height (Z)
tab_d = 0.012;
tab_len = 0.016;

// Thin end taper
thin_end_taper_len = 0.070;
thin_end_min_radial = 0.012;

// Small overlap for watertight unions/differences
// NOTE: model is sub-mm; keep overlap small but non-zero
overlap = 0.002;

// ---------------- Helpers ----------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module bbox_limit() {
  cube([bbox_x, bbox_y, bbox_z], center=true);
}

// 2D ring sector (in XZ plane), then linear_extrude along Y
module ring_sector_2d(r_in, r_out, ang_deg) {
  intersection() {
    difference() {
      circle(r=r_out);
      circle(r=r_in);
    }
    // sector wedge centered on +X axis
    polygon(points=[
      [0,0],
      [r_out*2*cos(-ang_deg/2), r_out*2*sin(-ang_deg/2)],
      [r_out*2*cos( ang_deg/2), r_out*2*sin( ang_deg/2)]
    ]);
  }
}

module ring_sector_3d(r_in, r_out, ang_deg, y_th) {
  linear_extrude(height=y_th, center=true)
    ring_sector_2d(r_in, r_out, ang_deg);
}

// Place a child at a given angle on the mid-radius, oriented tangentially.
// Arc lies in XZ around Y axis.
module at_angle(ang_deg, r_mid) {
  rotate([0, -ang_deg, 0])
    translate([r_mid, 0, 0])
      rotate([0, 90, 0])
        children();
}

// ---------------- Main geometry ----------------
module ribs_base() {
  // Two concentric ribs: outer and inner
  union() {
    ring_sector_3d(arc_outer_R - rib_thickness_radial, arc_outer_R, arc_angle_deg, part_thickness_y);
    ring_sector_3d(arc_inner_R, arc_inner_R + rib_thickness_radial, arc_angle_deg, part_thickness_y);
  }
}

// Tapered slot cutter: hull of two tangential boxes at arc ends
// FIX: ensure cutter actually intersects the ribs (radially) and stays centered in Z.
module tapered_slot_cutter() {
  r_mid = (arc_outer_R + arc_inner_R)/2;

  // Tangential cutter length: long enough to span across the rib thickness along tangent
  slot_len = clamp(bbox_z*0.95, 0.22, 0.38);

  // Gap between ribs (radial)
  gap_rad = (arc_outer_R - rib_thickness_radial) - (arc_inner_R + rib_thickness_radial);

  // Make cutter radial height exceed the gap so it fully opens the slot
  slot_radial_h_start = max(gap_rad + 2*overlap, slot_width_start + 2*overlap);
  slot_radial_h_end   = max(gap_rad + 2*overlap, slot_width_end   + 2*overlap);

  hull() {
    // thick end: wider
    at_angle( arc_angle_deg/2 - 1, r_mid)
      cube([slot_len, part_thickness_y + 4*overlap, slot_radial_h_start], center=true);

    // thin end: narrower
    at_angle(-arc_angle_deg/2 + 1, r_mid)
      cube([slot_len, part_thickness_y + 4*overlap, slot_radial_h_end], center=true);
  }
}

// Thick end block at +end of arc, connected by overlap into ribs
// FIX: place block so its inner tangential face overlaps the rib end (no floating).
module thick_end_block() {
  r_mid = (arc_outer_R + arc_inner_R)/2;

  at_angle( arc_angle_deg/2, r_mid) {
    // Ensure overlap with rib end: inner face at x = -end_block_len/2 + overlap
    translate([end_block_len/2 - overlap, 0, 0])
      cube([end_block_len, part_thickness_y, end_block_height_z], center=true);
  }
}

// Small protruding tab/peg on thick end block
// FIX: attach to the outer tangential face of the end block with overlap.
module end_tab_peg() {
  r_mid = (arc_outer_R + arc_inner_R)/2;

  at_angle( arc_angle_deg/2, r_mid) {
    // Outer face of end block is at x = (end_block_len/2 - overlap) + end_block_len/2 = end_block_len - overlap
    // Place peg so it overlaps that face by 'overlap'
    translate([end_block_len - overlap + tab_len/2 - overlap, 0, 0])
      rotate([0, 90, 0])
        cylinder(d=tab_d, h=tab_len, center=true);
  }
}

// Thin tapered end at -end of arc: a wedge that blends into ribs
// FIX: ensure it overlaps the rib end and is part of the same connected component.
module thin_end_taper() {
  r_mid = (arc_outer_R + arc_inner_R)/2;

  at_angle(-arc_angle_deg/2, r_mid) {
    // Build a tangential wedge that starts overlapping the rib end and extends outward.
    // Use a small but non-zero base length so it unions robustly with the rib end.
    base_len = max(overlap*8, 0.010);

    hull() {
      // base: overlaps ribs at the arc end (extends slightly into the rib end by overlap)
      translate([base_len/2 - overlap, 0, 0])
        cube([base_len, part_thickness_y, rib_thickness_radial*2 + overlap*2], center=true);

      // tip: thinner, moved along +X (tangent direction) by taper length
      translate([thin_end_taper_len + base_len/2 - overlap, 0, 0])
        cube([base_len, part_thickness_y, thin_end_min_radial], center=true);
    }
  }
}

// Assemble connected solid
module clip_body() {
  union() {
    difference() {
      ribs_base();
      tapered_slot_cutter();
    }
    thick_end_block();
    end_tab_peg();
    thin_end_taper();
  }
}

// Final: clip to bounding box (keeps within requested overall size)
intersection() {
  clip_body();
  bbox_limit();
}
}
