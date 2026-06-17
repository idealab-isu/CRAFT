// Bi-metal saw blade (sheet) - fixed for visible, connected geometry with toothed edge
// One connected solid, no floating parts, no text.

// ---------------- Parameters ----------------
blade_L = 300; //[150:600:1]
blade_W = 25;  //[12.5:50:1]
blade_T = 0.9; //[0.45:1.8:0.05]

tooth_pitch = 2.0; //[1.0:4.0:0.1]
tooth_H = 1.2;     //[0.6:2.4:0.1]
tooth_tip_angle = 60; //[30:90:1]

mount_hole_d = 6; //[3:12:0.5]
mount_hole_edge_offset = 12; //[6:24:1]
mount_hole_spacing = 25; //[12.5:50:1]
mount_slot_L = 12; //[6:24:1]

bimetal_band_W = 3.0; //[1.5:6.0:0.1]
bimetal_band_step_T = 0.2; //[0.1:0.5:0.05]

corner_R = 2.0; //[0.5:5.0:0.1]
edge_chamfer = 0.4; //[0.1:1.0:0.05]

overlap = 0.2; //[0.05:1.0:0.05]
tooth_set_offset = 0.25; //[0.1:0.6:0.05]

// ---------------- Quality ----------------
$fn = 64;

// ---------------- Helpers ----------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_rect_2d(L, W, R) {
  R2 = clamp(R, 0, min(L, W)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(L/2 - R2), sy*(W/2 - R2)]) circle(r=R2);
  }
}

module blade_plate() {
  linear_extrude(height=blade_T, center=true)
    rounded_rect_2d(blade_L, blade_W, corner_R);
}

module bimetal_band() {
  // Slightly thicker band along toothed edge (bottom edge in Y-), connected by overlap
  band_T = blade_T + bimetal_band_step_T;
  // Ensure band overlaps the plate in Z so union is watertight
  translate([0, -blade_W/2 + bimetal_band_W/2, 0])
    cube([blade_L, bimetal_band_W, band_T], center=true);
}

module mounting_slot_and_holes_cut() {
  // Slot centered between two holes near one end (left end)
  zH = (blade_T + bimetal_band_step_T) + 4*overlap;

  x1 = -blade_L/2 + mount_hole_edge_offset;
  x2 = x1 + mount_hole_spacing;
  xc = (x1 + x2)/2;

  union() {
    translate([x1, 0, 0]) cylinder(h=zH, r=mount_hole_d/2, center=true);
    translate([x2, 0, 0]) cylinder(h=zH, r=mount_hole_d/2, center=true);

    hull() {
      translate([xc - mount_slot_L/2, 0, 0]) cylinder(h=zH, r=mount_hole_d/2, center=true);
      translate([xc + mount_slot_L/2, 0, 0]) cylinder(h=zH, r=mount_hole_d/2, center=true);
    }
  }
}

module edge_chamfer_cut() {
  // Small top/bottom chamfer approximation: remove thin slabs near top/bottom
  // Keep conservative so it doesn't erase the blade.
  zH = (blade_T + bimetal_band_step_T) + 4*overlap;
  ch = clamp(edge_chamfer, 0, blade_T*0.45);

  union() {
    translate([0, 0, (blade_T/2) - ch/2])
      cube([blade_L + 4*overlap, blade_W + 4*overlap, ch], center=true);
    translate([0, 0, -(blade_T/2) + ch/2])
      cube([blade_L + 4*overlap, blade_W + 4*overlap, ch], center=true);
  }
}

module tooth_2d() {
  // Base at y=0, tooth points toward -Y
  tip_w = max(0.15, tooth_pitch * 0.25);
  tip_w2 = clamp(tip_w * (tooth_tip_angle/60), 0.12, tooth_pitch*0.45);

  polygon(points=[
    [-tooth_pitch/2, 0],
    [ tooth_pitch/2, 0],
    [ tip_w2/2, -tooth_H],
    [-tip_w2/2, -tooth_H]
  ]);
}

module teeth_row() {
  // Teeth added and overlapped into the bimetal band for guaranteed connectivity.
  band_T = blade_T + bimetal_band_step_T;

  // Place tooth base slightly INSIDE the band (toward +Y) so it fuses with band.
  // Band spans Y: [-blade_W/2, -blade_W/2 + bimetal_band_W]
  y_base = (-blade_W/2 + bimetal_band_W) - overlap;

  n = max(2, floor(blade_L / tooth_pitch));
  x0 = -blade_L/2 + tooth_pitch/2;

  for (i = [0 : n-1]) {
    x = x0 + i*tooth_pitch;
    set = (i % 2 == 0) ? tooth_set_offset : -tooth_set_offset;

    translate([x, y_base + set, 0])
      linear_extrude(height=band_T, center=true)
        tooth_2d();
  }
}

module gullets_cut() {
  // Circular gullets between teeth, cut into teeth/band
  band_T = blade_T + bimetal_band_step_T;
  zH = band_T + 4*overlap;

  r = clamp(tooth_pitch * 0.28, 0.2, tooth_pitch*0.45);

  n = max(2, floor(blade_L / tooth_pitch));
  x0 = -blade_L/2 + tooth_pitch; // between teeth

  // Put gullets near tooth root, inside the band so they carve visible scallops
  y_g = (-blade_W/2 + bimetal_band_W) - tooth_H*0.15;

  for (i = [0 : n-2]) {
    x = x0 + i*tooth_pitch;
    translate([x, y_g, 0])
      cylinder(h=zH, r=r, center=true);
  }
}

// ---------------- Final Model ----------------
module blade_complete() {
  // Ensure non-degenerate parameters
  assert(blade_L > 0 && blade_W > 0 && blade_T > 0);
  assert(bimetal_band_W > 0 && bimetal_band_W <= blade_W);

  difference() {
    union() {
      blade_plate();
      bimetal_band();
      teeth_row();
    }
    mounting_slot_and_holes_cut();
    gullets_cut();
    edge_chamfer_cut();
  }
}

blade_complete();