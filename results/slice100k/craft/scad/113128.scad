// Stepped, asymmetric H-like bracket/block (prismatic, sharp edges)
// Target bounding box: 31.8 x 31.8 x 15.8 mm

$fn = 48;

// --- Parameters (mm) ---
bbox_x = 31.8;
bbox_y = 31.8;
bbox_z = 15.8;

// H core (two end blocks + central bridge)
end_block_x = 12.0;
end_block_y = bbox_y;
end_block_z = bbox_z;

bridge_x = bbox_x - 2*end_block_x;   // ensures exact bbox_x
bridge_y = 12.0;
bridge_z = bbox_z;

// Shoulder steps / rebates (cuts)
top_rebate_depth = 2.0;
top_rebate_y     = 18.0;
top_rebate_x     = bbox_x;

bottom_rebate_depth = 2.5;
bottom_rebate_y     = 14.0;
bottom_rebate_x     = 20.0;

// Asymmetric pads (additions) - made more pronounced
pad_top_x = 12.0;
pad_top_y = 9.0;
pad_top_z = 3.0;
pad_top_offset_x = 6.8;
pad_top_offset_y = 9.2;

pad_bottom_x = 9.5;
pad_bottom_y = 12.0;
pad_bottom_z = 3.5;
pad_bottom_offset_x = -8.2;
pad_bottom_offset_y = -7.6;

// Small lip on top (addition)
lip_x = 7.0;
lip_y = 4.5;
lip_z = 1.5;
lip_offset_x = 0.0;
lip_offset_y = -10.2;

// Corner relief notches (cuts)
notch_x = 3.0;
notch_y = 3.0;
notch_z = 4.0;

overlap = 0.25; // overlap to guarantee manifold unions/differences

// --- Core H solid (union of 3 prisms) ---
module h_core() {
  union() {
    // left end block
    translate([-(bbox_x/2 - end_block_x/2), 0, 0])
      cube([end_block_x, end_block_y, end_block_z], center=true);

    // right end block
    translate([(bbox_x/2 - end_block_x/2), 0, 0])
      cube([end_block_x, end_block_y, end_block_z], center=true);

    // central bridge (exactly spans between end blocks)
    cube([bridge_x, bridge_y, bridge_z], center=true);
  }
}

// --- Add asymmetric pads and lip (all connected) ---
module additions() {
  union() {
    // top offset pad (sits on top face, overlaps into body)
    translate([pad_top_offset_x, pad_top_offset_y,
               bbox_z/2 - pad_top_z/2 - overlap])
      cube([pad_top_x, pad_top_y, pad_top_z], center=true);

    // bottom offset pad (sits on bottom face, overlaps into body)
    translate([pad_bottom_offset_x, pad_bottom_offset_y,
               -(bbox_z/2 - pad_bottom_z/2 - overlap)])
      cube([pad_bottom_x, pad_bottom_y, pad_bottom_z], center=true);

    // small alignment lip protruding from top face, overlaps slightly
    translate([lip_offset_x, lip_offset_y,
               bbox_z/2 + lip_z/2 - overlap])
      cube([lip_x, lip_y, lip_z], center=true);
  }
}

// --- Shoulder steps/rebates (cuts) ---
module top_rebate_cut() {
  translate([0, 0, bbox_z/2 - top_rebate_depth/2 + overlap])
    cube([top_rebate_x + 2*overlap,
          top_rebate_y + 2*overlap,
          top_rebate_depth + 2*overlap], center=true);
}

module bottom_rebate_cut() {
  translate([0, 0, -(bbox_z/2 - bottom_rebate_depth/2 + overlap)])
    cube([bottom_rebate_x + 2*overlap,
          bottom_rebate_y + 2*overlap,
          bottom_rebate_depth + 2*overlap], center=true);
}

// --- Corner relief notches (cuts) ---
module corner_notches_cut() {
  for (sx = [-1, 1], sy = [-1, 1]) {
    translate([sx*(bbox_x/2 - notch_x/2),
               sy*(bbox_y/2 - notch_y/2),
               bbox_z/2 - notch_z/2 + overlap])
      cube([notch_x + 2*overlap,
            notch_y + 2*overlap,
            notch_z + 2*overlap], center=true);
  }
}

// --- Final model (ONE connected solid) ---
difference() {
  union() {
    h_core();
    additions();
  }
  top_rebate_cut();
  bottom_rebate_cut();
  corner_notches_cut();
}