// IEC C14 switched fused inlet module (approx) - 40.0mm x 27.0mm panel cutout
// One connected solid, with visible C14 cavity + switch + fuse drawer features

$fn = 64;

// -------------------- Parameters --------------------
cutout_W = 40.0;   // panel cutout width (X)
cutout_H = 27.0;   // panel cutout height (Y)
panel_t  = 2.0;

body_D       = 45.0;  // depth behind panel (Z-)
body_wall_t  = 2.0;

flange_W = 44.0;
flange_H = 31.0;
flange_t = 2.5;

front_bezel_t = 1.5;
bezel_frame_t = 1.5;
bezel_recess_d = 0.8;

clip_overhang = 1.5;
clip_H = 6.0;
clip_t = 1.2;

screw_hole_d = 3.2;
screw_edge_margin = 5.0;

pin_recess_W = 26.0;
pin_recess_H = 18.0;
pin_recess_d = 10.0;   // deeper so cavity is clearly visible from front

switch_W = 18.0;
switch_H = 12.0;
switch_t = 3.0;

fuse_W = 22.0;
fuse_H = 10.0;
fuse_t = 3.0;

overlap = 0.8;

// -------------------- Helpers --------------------
module rounded_rect_prism(size=[10,10,10], r=1, center=true) {
  // 2D rounded rectangle extruded
  linear_extrude(height=size[2], center=center)
    offset(r=r)
      square([size[0]-2*r, size[1]-2*r], center=true);
}

// Coordinate convention:
// Panel plane at z=0. Front is +Z, rear is -Z.
// Flange/bezel are on +Z side, body extends to -Z.

// -------------------- Base solids --------------------
module main_body_outer() {
  // Outer body sits behind panel, touching it with slight overlap
  translate([0,0, -body_D/2 - panel_t/2 + overlap])
    cube([cutout_W, cutout_H, body_D], center=true);
}

module main_body_inner_void() {
  // Inner void to make shell
  translate([0,0, -body_D/2 - panel_t/2 + overlap])
    cube([cutout_W - 2*body_wall_t, cutout_H - 2*body_wall_t, body_D - 2*body_wall_t], center=true);
}

module front_flange() {
  translate([0,0, panel_t/2 + flange_t/2 - overlap])
    cube([flange_W, flange_H, flange_t], center=true);
}

module front_bezel_frame() {
  // A raised frame on the front
  difference() {
    translate([0,0, panel_t/2 + flange_t + front_bezel_t/2 - overlap])
      cube([flange_W - 2*body_wall_t, flange_H - 2*body_wall_t, front_bezel_t], center=true);

    translate([0,0, panel_t/2 + flange_t + front_bezel_t/2 - overlap])
      cube([cutout_W - 2*bezel_frame_t, cutout_H - 2*bezel_frame_t, front_bezel_t + 2*overlap], center=true);
  }
}

module side_clips() {
  // Simple snap tabs on left/right, connected to body at panel plane
  union() {
    // right tab
    translate([cutout_W/2 + clip_t/2 - overlap, 0, -panel_t/2 + overlap])
      cube([clip_t, clip_H, panel_t + 2*overlap], center=true);
    translate([cutout_W/2 + clip_t - overlap + (clip_overhang + overlap)/2, 0, -panel_t/2 + overlap])
      cube([clip_overhang + overlap, clip_H, panel_t + 2*overlap], center=true);

    // left tab
    translate([-cutout_W/2 - clip_t/2 + overlap, 0, -panel_t/2 + overlap])
      cube([clip_t, clip_H, panel_t + 2*overlap], center=true);
    translate([-cutout_W/2 - clip_t + overlap - (clip_overhang + overlap)/2, 0, -panel_t/2 + overlap])
      cube([clip_overhang + overlap, clip_H, panel_t + 2*overlap], center=true);
  }
}

// -------------------- Front features (positive geometry) --------------------
module rocker_switch_boss() {
  // Raised switch area on front (top region)
  translate([0, cutout_H/2 - switch_H/2 - body_wall_t, panel_t/2 + flange_t + switch_t/2 - overlap])
    rounded_rect_prism([switch_W, switch_H, switch_t], r=1.2, center=true);
}

module fuse_drawer_boss() {
  // Raised fuse drawer area on front (bottom region)
  translate([0, -cutout_H/2 + fuse_H/2 + body_wall_t, panel_t/2 + flange_t + fuse_t/2 - overlap])
    rounded_rect_prism([fuse_W, fuse_H, fuse_t], r=1.0, center=true);
}

// -------------------- Subtractive details --------------------
module c14_front_cavity_cut() {
  // Main C14 opening from the front into the body
  // Starts at front bezel plane and goes deep into body.
  cavity_depth = panel_t + flange_t + front_bezel_t + pin_recess_d + 2*overlap;
  z_center = (panel_t/2 + flange_t + front_bezel_t) - overlap - cavity_depth/2;

  translate([0, 0, z_center])
    rounded_rect_prism([pin_recess_W, pin_recess_H, cavity_depth], r=2.0, center=true);
}

module c14_key_notch_cut() {
  // Small key notch at top of C14 cavity (typical C14 shape cue)
  notch_W = pin_recess_W * 0.45;
  notch_H = pin_recess_H * 0.18;
  notch_depth = pin_recess_d * 0.75;

  cavity_depth = panel_t + flange_t + front_bezel_t + notch_depth + 2*overlap;
  z_center = (panel_t/2 + flange_t + front_bezel_t) - overlap - cavity_depth/2;

  translate([0, pin_recess_H/2 - notch_H/2 - 1.0, z_center])
    cube([notch_W, notch_H, cavity_depth], center=true);
}

module pin_holes_cut() {
  // Three pin holes inside cavity (visual cue)
  // Oriented along Z (depth), placed on a triangle pattern in X/Y.
  hole_d = 4.2;
  hole_len = pin_recess_d + 6; // extend beyond cavity for clean cut

  // Place holes so they are visible from front and inside cavity
  z_center = -panel_t/2 - (pin_recess_d/2); // behind panel
  y0 = -1.0;
  x_off = 6.5;
  y_top = 4.5;

  for (p = [[-x_off, y0], [x_off, y0], [0, y_top]]) {
    translate([p[0], p[1], z_center])
      rotate([90,0,0])  // make cylinder axis along Y? We'll instead align along Z by default:
        ; // no-op
  }

  // Cylinders along Z (default) -> no rotate needed
  for (p = [[-x_off, y0], [x_off, y0], [0, y_top]]) {
    translate([p[0], p[1], -panel_t/2 - hole_len/2])
      cylinder(d=hole_d, h=hole_len, center=true);
  }
}

module switch_recess_cut() {
  // Recess in the switch boss to show a rocker opening
  recess_d = min(1.2, switch_t - 0.6);
  z_center = panel_t/2 + flange_t + switch_t - recess_d/2 - overlap;

  translate([0, cutout_H/2 - switch_H/2 - body_wall_t, z_center])
    rounded_rect_prism([switch_W*0.86, switch_H*0.70, recess_d + 2*overlap], r=1.0, center=true);
}

module fuse_recess_cut() {
  // Recess in fuse drawer boss to show drawer face
  recess_d = min(1.2, fuse_t - 0.6);
  z_center = panel_t/2 + flange_t + fuse_t - recess_d/2 - overlap;

  translate([0, -cutout_H/2 + fuse_H/2 + body_wall_t, z_center])
    rounded_rect_prism([fuse_W*0.88, fuse_H*0.72, recess_d + 2*overlap], r=0.8, center=true);
}

module fuse_finger_notch_cut() {
  // Small notch on fuse drawer (bottom edge) for finger pull
  notch_w = fuse_W*0.35;
  notch_h = fuse_H*0.25;
  notch_d = fuse_t + 2*overlap;

  z_center = panel_t/2 + flange_t + fuse_t/2 - overlap;
  y_center = -cutout_H/2 + fuse_H/2 + body_wall_t - fuse_H*0.30;

  translate([0, y_center, z_center])
    cube([notch_w, notch_h, notch_d], center=true);
}

module label_recesses_cut() {
  // Shallow recesses above switch and above fuse (no text)
  z_center = panel_t/2 + flange_t + front_bezel_t - (bezel_recess_d + overlap)/2;

  translate([0, cutout_H/2 - switch_H/2 - body_wall_t, z_center])
    cube([switch_W, switch_H/2, bezel_recess_d + overlap], center=true);

  translate([0, -cutout_H/2 + fuse_H/2 + body_wall_t, z_center])
    cube([fuse_W, fuse_H/2, bezel_recess_d + overlap], center=true);
}

module screw_holes_cut() {
  // Through-holes in flange/bezel (axis along Y)
  hole_len = flange_t + front_bezel_t + 2*overlap;
  z_center = panel_t/2 + (flange_t + front_bezel_t)/2 - overlap;

  translate([-flange_W/2 + screw_edge_margin, 0, z_center])
    rotate([90,0,0])
      cylinder(d=screw_hole_d, h=hole_len, center=true);

  translate([flange_W/2 - screw_edge_margin, 0, z_center])
    rotate([90,0,0])
      cylinder(d=screw_hole_d, h=hole_len, center=true);
}

// -------------------- Assembly --------------------
module inlet_module() {
  difference() {
    union() {
      // Shell body
      difference() {
        main_body_outer();
        main_body_inner_void();
      }

      // Front mounting features
      front_flange();
      front_bezel_frame();

      // Clips
      side_clips();

      // Switch + fuse bosses (positive geometry)
      rocker_switch_boss();
      fuse_drawer_boss();
    }

    // C14 cavity + details
    c14_front_cavity_cut();
    c14_key_notch_cut();
    pin_holes_cut();

    // Switch + fuse recess details
    switch_recess_cut();
    fuse_recess_cut();
    fuse_finger_notch_cut();

    // Label recesses (blank)
    label_recesses_cut();

    // Screw holes
    screw_holes_cut();
  }
}

// Final
inlet_module();