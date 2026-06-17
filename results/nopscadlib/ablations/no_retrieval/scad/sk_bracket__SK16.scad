$fn = 96;

// Parameters
rod_d = 16; //[8:32:0.1]
bracket_h = 27; //[14:54:0.5]

base_L = 60; //[30:120:1]
base_W = 30; //[15:60:1]
base_T = 8; //[4:16:0.5]

support_block_L = 30; //[15:60:1]
support_block_W = 30; //[15:60:1]

bore_clearance = 0.2; //[0:0.8:0.05]

mount_hole_d = 6.5; //[3:10:0.1]
mount_hole_spacing = 40; //[20:80:1]

clamp_split_w = 2; //[0.8:4:0.1]
overlap = 1; //[0.5:2:0.1]

counterbore_d = 11; //[8:18:0.5]
counterbore_depth = 4; //[2:8:0.5]

set_screw_d = 5; //[3:8:0.1]
set_screw_z = 13.5; //[8:20:0.5]

lighten_window_W = 12; //[6:24:0.5]
lighten_window_L = 18; //[10:28:0.5]
lighten_window_H = 10; //[6:16:0.5]

// Derived (enforce critical overall height)
support_block_H = bracket_h - base_T; // ensures overall height == bracket_h

// Base Block
module base_block() {
  translate([0, 0, base_T/2])
    cube([base_L, base_W, base_T], center=true);
}

// Support Block (connected to base with overlap)
module support_block() {
  translate([0, 0, base_T + support_block_H/2 - overlap])
    cube([support_block_L, support_block_W, support_block_H], center=true);
}

// Rod Support Bore (through support block along Y)
module rod_support_bore() {
  translate([0, 0, base_T + support_block_H/2])
    rotate([90, 0, 0])
      cylinder(h=support_block_W + 2*overlap,
               r=(rod_d + bore_clearance)/2,
               center=true);
}

// Mounting Holes (through base)
module mount_holes() {
  for (sx = [-1, 1])
    translate([sx*mount_hole_spacing/2, 0, base_T/2])
      cylinder(h=base_T + 2*overlap, r=mount_hole_d/2, center=true);
}

// Mounting Hole Counterbores (from bottom face into base)
module mount_counterbores() {
  for (sx = [-1, 1])
    translate([sx*mount_hole_spacing/2, 0, counterbore_depth/2])
      cylinder(h=counterbore_depth + 2*overlap, r=counterbore_d/2, center=true);
}

// Rod Clamp Split (slot through support block along Y)
module rod_clamp_split() {
  translate([0, 0, base_T + support_block_H/2])
    cube([support_block_L + 2*overlap,
          clamp_split_w,
          support_block_H + 2*overlap], center=true);
}

// Set Screw Hole (through support block along X)
module set_screw_hole() {
  translate([0, 0, set_screw_z])
    rotate([0, 90, 0])
      cylinder(h=support_block_L + 2*overlap, r=set_screw_d/2, center=true);
}

// Lightening Cutouts (kept within support block)
module lightening_cutouts() {
  zc = base_T + support_block_H/2;
  dz = (support_block_H - lighten_window_H)/2;
  for (sz = [-1, 1])
    translate([0, 0, zc + sz*dz])
      cube([lighten_window_L, lighten_window_W, lighten_window_H], center=true);
}

// Final Bracket Assembly (one connected solid)
difference() {
  union() {
    base_block();
    support_block();
  }
  mount_holes();
  mount_counterbores();
  rod_support_bore();
  rod_clamp_split();
  set_screw_hole();
  lightening_cutouts();
}