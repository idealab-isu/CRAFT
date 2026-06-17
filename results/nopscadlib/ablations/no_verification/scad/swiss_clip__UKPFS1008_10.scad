// Parameters
clip_type = 0; //[0:2:1]
open_ratio = 0.9; //[0.2:1:0.05]
include_spigot_hole = 0; //[0:1:1]
hole_depth = 0; //[0:30:1]
L = 45; //[25:90:1]
W = 18; //[10:36:1]
H = 22; //[12:44:1]
t = 0.8; //[0.4:1.6:0.1]
bend_r = 2.5; //[1.2:5:0.1]
arm_l = 16; //[8:32:1]
arm_w = 4; //[2:8:0.5]
hinge_offset = 14; //[7:28:1]
hook_x = 10; //[5:20:1]
hook_y = 10; //[6:20:1]
spigot_x = 8; //[4:16:1]
spigot_y = 6; //[3:12:0.5]
spigot_z = 10; //[5:20:1]
overlap = 1; //[0.5:2:0.1]
arm_angle_deg = 35; //[5:70:1]
spigot_angle_deg = 25; //[5:60:1]
gusset_thickness = 0.8; //[0.4:1.6:0.1]
gusset_len = 6; //[3:12:0.5]
hole_clearance = 0.2; //[0:0.6:0.05]

$fn = 64;

function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module swiss_clip_solid() {
  // Ensure sane geometry
  Lc = max(L, 10);
  Wc = max(W, 6);
  tc = max(t, 0.4);
  Hr = max(H, tc*3);
  br = max(bend_r, tc*1.2);
  ov = clamp(overlap, 0.2, 3);

  // Key x-positions (all derived)
  x_left = -Lc/2;
  x_right =  Lc/2;

  // Hinge center near right side
  x_hinge = x_right - hinge_offset;

  // Hook region at left
  hook_len = clamp(hook_x, tc*2, Lc*0.6);
  hook_w   = clamp(hook_y, tc*3, Wc);
  x_hook_mid = x_left + hook_len/2;

  // Spigot region at right
  spx = clamp(spigot_x, tc*2, Lc*0.5);
  spy = clamp(spigot_y, tc*3, Wc);
  spz = clamp(spigot_z, tc*3, Hr);
  x_spigot_mid = x_right - spx/2;

  // Arms
  al = clamp(arm_l, tc*4, Lc*0.7);
  aw = clamp(arm_w, tc*2, Wc/2);
  arm_ang = arm_angle_deg * open_ratio;
  sp_ang  = spigot_angle_deg * open_ratio;

  // Place arms so their inner ends overlap the hinge region (connectivity)
  // Inner end x is at x_hinge - ov, so center is shifted by al/2 from that.
  x_arm_center = (x_hinge - ov) - al/2;

  // Z placement: keep everything around z=0 plane with slight overlaps
  z_plate = 0;
  z_up = tc/2;

  color([0.15, 0.2, 0.35])
  union() {

    // Main base plate (backbone)
    translate([0, 0, z_plate])
      cube([Lc, Wc, tc], center=true);

    // Left hook: U-shaped vertical return (connected to base)
    // Bottom lip (overlaps base)
    translate([x_hook_mid, 0, z_plate])
      cube([hook_len, hook_w, tc], center=true);

    // Vertical wall at extreme left (connects bottom and top lips)
    translate([x_left + tc/2 - ov, 0, (Hr - tc)/2])
      cube([tc + 2*ov, hook_w, Hr - tc], center=true);

    // Top lip
    translate([x_hook_mid, 0, Hr - tc/2])
      cube([hook_len, hook_w, tc], center=true);

    // Hinge/bend: a thickened band across width (connected to base)
    // Use a cylinder rotated to run along Y, centered at hinge x.
    translate([x_hinge, 0, br - tc/2])
      rotate([90, 0, 0])
        cylinder(r=br, h=Wc + 2*ov, center=true);

    // Add a small rectangular bridge under hinge to guarantee manifold connection
    translate([x_hinge, 0, z_plate])
      cube([2*br + tc, Wc, tc], center=true);

    // Spigot section: keep it connected by rotating around hinge line
    // Rotate about Y around hinge x, then place spigot relative to global.
    translate([x_hinge, 0, 0])
      rotate([0, -sp_ang, 0])
        translate([x_spigot_mid - x_hinge, 0, 0]) {
          // Spigot base pad (overlaps main plate)
          translate([0, 0, z_plate])
            cube([spx, spy, tc], center=true);

          // Spigot upright (overlaps pad)
          translate([spx/2 - tc/2 + ov, 0, tc/2 + spz/2 - ov])
            cube([tc + 2*ov, spy, spz], center=true);
        }

    // Spring arms: rotate about hinge line and overlap into hinge band
    translate([x_hinge, 0, 0])
      rotate([0, arm_ang, 0]) {
        // Left/right arms along Y edges
        translate([x_arm_center - x_hinge, -(Wc/2 - aw/2), z_up])
          cube([al, aw, tc], center=true);
        translate([x_arm_center - x_hinge,  (Wc/2 - aw/2), z_up])
          cube([al, aw, tc], center=true);

        // Small arm roots to ensure robust connection into hinge band
        root_len = max(tc*3, ov*2);
        translate([-(ov + root_len/2), -(Wc/2 - aw/2), z_up])
          cube([root_len, aw, tc], center=true);
        translate([-(ov + root_len/2),  (Wc/2 - aw/2), z_up])
          cube([root_len, aw, tc], center=true);
      }

    // Gussets: connect arms to base near hinge (kept unrotated for solidity)
    gl = clamp(gusset_len, tc*3, Lc*0.4);
    gt = clamp(gusset_thickness, tc*0.8, tc*3);

    // Center gusset
    translate([x_hinge - gl/2 + ov, 0, tc/2 + gt/2 - ov])
      cube([gl, Wc - 2*aw, gt], center=true);

    // Side gussets under arms
    translate([x_hinge - gl/2 + ov, -(Wc/2 - aw/2), tc/2 + gt/2 - ov])
      cube([gl, aw, gt], center=true);
    translate([x_hinge - gl/2 + ov,  (Wc/2 - aw/2), tc/2 + gt/2 - ov])
      cube([gl, aw, gt], center=true);
  }
}

module swiss_clip() {
  // Optional hole is a subtraction to keep one connected solid
  if (include_spigot_hole) {
    // Hole aligned through spigot upright (approx), derived from spigot dims and hinge
    Lc = max(L, 10);
    tc = max(t, 0.4);
    br = max(bend_r, tc*1.2);
    spx = clamp(spigot_x, tc*2, Lc*0.5);
    spy = clamp(spigot_y, tc*3, W);
    spz = clamp(spigot_z, tc*3, H);
    x_right =  Lc/2;
    x_hinge = x_right - hinge_offset;
    x_spigot_mid = x_right - spx/2;
    sp_ang  = spigot_angle_deg * open_ratio;

    hole_r = sqrt((spy/2)*(spy/2) + (spz/2)*(spz/2)) + hole_clearance;
    hole_h = (hole_depth > 0) ? hole_depth : (spx + 2*br + 2*tc);

    difference() {
      swiss_clip_solid();

      // Place hole by applying same hinge rotation used for spigot, then drilling along X
      translate([x_hinge, 0, 0])
        rotate([0, -sp_ang, 0])
          translate([x_spigot_mid - x_hinge + spx/2 - tc/2, 0, tc/2 + spz/2])
            rotate([0, 90, 0])
              cylinder(r=hole_r, h=hole_h, center=true);
    }
  } else {
    swiss_clip_solid();
  }
}

swiss_clip();