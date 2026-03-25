// Swiss clip (blocky rounded clip with C/slot cutout + cylindrical hole feature)
// FIX: attach ALL small pieces (side + top/bottom) so NOTHING floats.
// All parts are unioned and overlap 1-2mm into the main body for guaranteed connectivity.

sclip_type_selector = 0; //[0:2:1]
open = 0.9; //[0:1:0.05]
overlap = 1; //[0.5:2:0.1]
t = 0.8; //[0.4:1.6:0.05]
length = 55; //[30:110:1]
width = 18; //[10:36:1]
height = 22; //[12:44:1]
arm_l = 18; //[10:36:1]
arm_w = 4; //[2:8:0.5]
hinge_offset = 16; //[8:32:1]
bend_or = 3; //[1.5:6:0.25]
hook_x = 14; //[8:28:1]
hook_y = 10; //[6:20:1]
spigot_x = 10; //[6:20:1]
spigot_y = 8; //[5:16:1]
spigot_z = 12; //[6:24:1]
arm_angle_max = 25; //[10:45:1]
spigot_angle_max = 18; //[5:35:1]
hole_clearance = 0.2; //[0.1:0.6:0.05]
hole_depth = 6; //[1:20:1]
show_hole = 1; //[0:1:1]
w_narrow = 10; //[6:24:1]
gusset_thickness = 0.8; //[0.4:1.6:0.05]

$fn = 96;
eps = 0.02;

// ---- Derived dimensions ----
L = length;
W = width;
H = height;

// Corner radius for the outer block (rounded rectangle)
r_outer = min(W, H) * 0.28;

// Wall thickness (printable)
wall = max(t*2, 1.6);

// Slot (C opening) width controlled by open
slot_min = wall*1.2;
slot_max = W*0.65;
slot_w   = slot_min + (slot_max - slot_min) * open;

// Inner cavity size (keeps a C-shaped cross-section)
inner_W = max(W - 2*wall, wall*1.2);
inner_H = max(H - 2*wall, wall*1.2);
r_inner = max(r_outer - wall, wall*0.6);

// Back spine thickness (keeps clip connected and blocky)
spine = max(wall*1.4, 2.0);

// Small end rounding "caps" (integrated, not separate plates)
end_cap_r = min(W, H) * 0.22;
end_cap_len = max(wall*1.6, 2.2);

// ---- Helpers ----
module rounded_rect_2d(w, h, r) {
  r2 = min(r, w/2, h/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
  }
}

module swiss_clip_body_solid() {
  // Solid outer body (no hole subtraction here)
  difference() {
    union() {
      // Main body (rounded block extruded along X)
      linear_extrude(height=L, center=true)
        rounded_rect_2d(W, H, r_outer);

      // Integrated end bulges (subtle, connected)
      for (sx = [-1, 1]) {
        translate([sx*(L/2 - end_cap_len/2 + eps), 0, 0])
          rotate([0, 90, 0])
            cylinder(r=end_cap_r, h=end_cap_len + 2*eps, center=true);
      }

      // Slight back rib to emphasize clip spine (connected)
      rib_h = max(wall*0.9, 1.4);
      rib_w = W * 0.55;
      translate([0, 0, -H/2 + rib_h/2 - eps])
        linear_extrude(height=L*0.82, center=true)
          rounded_rect_2d(rib_w, rib_h, rib_h/2);
    }

    // Inner cavity (rounded rectangle) to create wall thickness
    linear_extrude(height=L + 2*eps, center=true)
      rounded_rect_2d(inner_W, inner_H, r_inner);

    // Side slot cut to create the characteristic C opening.
    slot_center_y = (W/2) - slot_w/2;
    translate([0, slot_center_y, 0])
      cube([L + 2*eps, slot_w, H + 2*eps], center=true);

    // Small mouth relief (rounded) to soften the slot edges
    relief_r = max(wall*0.7, 1.2);
    relief_y = (W/2) - relief_r*0.6;
    translate([0, relief_y, 0])
      rotate([0, 90, 0])
        cylinder(r=relief_r, h=L + 2*eps, center=true);
  }
}

module swiss_clip_side_tabs() {
  // Two small side tabs/clips (left/right) on +/-Y, overlapping into body.
  tab_overlap = 1.5; // 1-2mm overlap required

  tab_r = max(wall*0.9, 1.6);
  tab_thick_y = max(wall*1.2, 2.2);     // thickness in Y (outward)
  tab_len_x   = max(wall*2.0, 4.0);     // length along X
  tab_h_z     = max(wall*1.6, 3.2);     // height along Z

  x_pos = 0;
  y_center = (W/2) + (tab_thick_y/2) - tab_overlap;
  z_pos = 0;

  for (sy = [-1, 1]) {
    translate([x_pos, sy*y_center, z_pos])
      intersection() {
        hull() {
          translate([-tab_len_x/2 + tab_r, 0, 0])
            rotate([90, 0, 0]) cylinder(r=tab_r, h=tab_thick_y, center=true);
          translate([ tab_len_x/2 - tab_r, 0, 0])
            rotate([90, 0, 0]) cylinder(r=tab_r, h=tab_thick_y, center=true);
        }
        cube([tab_len_x + 2*eps, tab_thick_y + 2*eps, tab_h_z], center=true);
      }
  }
}

module swiss_clip_top_bottom_tabs() {
  // FIX: Add/attach the two small pieces above and below the main body (seen in left/right views).
  // These are placed on +/-Z and overlap into the main body by tab_overlap.
  tab_overlap = 1.5; // 1-2mm overlap required

  tab_r = max(wall*0.9, 1.6);
  tab_thick_z = max(wall*1.2, 2.2);     // thickness in Z (outward)
  tab_len_x   = max(wall*2.0, 4.0);     // length along X
  tab_w_y     = max(wall*1.6, 3.2);     // width along Y

  x_pos = 0;
  z_center = (H/2) + (tab_thick_z/2) - tab_overlap;
  y_pos = 0;

  for (sz = [-1, 1]) {
    translate([x_pos, y_pos, sz*z_center])
      intersection() {
        hull() {
          translate([-tab_len_x/2 + tab_r, 0, 0])
            rotate([0, 90, 0]) cylinder(r=tab_r, h=tab_len_x, center=true);
          translate([ tab_len_x/2 - tab_r, 0, 0])
            rotate([0, 90, 0]) cylinder(r=tab_r, h=tab_len_x, center=true);
        }
        cube([tab_len_x + 2*eps, tab_w_y, tab_thick_z + 2*eps], center=true);
      }
  }
}

module swiss_clip_hole() {
  // Cylindrical hole feature (through the body thickness), placed near one end.
  if (show_hole) {
    hole_r = max(min(H, W) * 0.16, 1.4) + hole_clearance;

    // Drill direction: along Z (top to bottom)
    y_safe = -W/2 + spine + hole_r + wall*0.4;
    y_pos = min(y_safe, -hole_r*0.2); // ensure stays on spine side
    x_pos = L/2 - (wall*2.2 + hole_r); // near +X end, derived

    translate([x_pos, y_pos, 0])
      cylinder(r=hole_r, h=H + 2*eps, center=true);
  }
}

// ---- Final model: single connected solid with attached tabs, then hole subtracted ----
difference() {
  union() {
    swiss_clip_body_solid();
    swiss_clip_side_tabs();        // attached on +/-Y with overlap
    swiss_clip_top_bottom_tabs();  // attached on +/-Z with overlap (FIX for floating top/bottom pieces)
  }
  swiss_clip_hole();
}