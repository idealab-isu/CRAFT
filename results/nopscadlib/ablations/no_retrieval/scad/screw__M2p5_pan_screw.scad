// Pan head screw with threads (ONE connected solid)
// Target dimensions:
// - Shank major Ø2.5
// - Head Ø4.7
// - Head height 1.7
// - Length 10 (under-head)

$fn = 128;

// ---------------- Parameters ----------------
shank_d   = 2.5;   // major diameter
length    = 10;    // under-head length

head_d    = 4.7;
head_h    = 1.7;

// Pan head profile controls (kept within head_h)
head_top_crown_h = 0.55;                 // height of rounded crown above the cylindrical skirt
head_skirt_h     = head_h - head_top_crown_h;

// Phillips recess (simple, consistent from top)
drive_d       = 2.4;   // overall cross width
drive_arm_w   = 0.6;   // arm thickness
drive_depth   = 1.05;  // recess depth (must be < head_h)

// Thread approximation (helical ridge)
pitch         = 0.55;  // mm per turn (approx for M2.5)
thread_h      = 0.22;  // radial height of thread above minor diameter
thread_flat   = 0.18;  // tangential thickness of ridge (controls sharpness)
thread_start_clear = 0.35; // unthreaded length under head
thread_end_clear   = 0.35; // unthreaded at tip

// Tip
tip_chamfer_h = 0.7;
tip_minor_reduction = 0.35; // reduces radius at tip

// Connectivity / robustness
overlap = 0.06;

// Z references (Z=0 at underside of head)
z_head_bottom = 0;
z_head_top    = head_h;
z_shank_top   = z_head_bottom;
z_shank_bot   = z_shank_top - length;

// ---------------- Helpers ----------------
function clamp(x,a,b) = x < a ? a : (x > b ? b : x);

// ---------------- Geometry ----------------
module pan_head_solid() {
  // Pan head: cylindrical skirt + rounded crown (not a ball)
  // Build in Z=[0..head_h]
  r = head_d/2;

  union() {
    // Skirt (straight side)
    translate([0,0,head_skirt_h/2])
      cylinder(h=head_skirt_h, r=r, center=true);

    // Crown: rotate_extrude a smooth arc that stays within head_h
    // Profile in (x,z): from (r, head_skirt_h) to (0, head_h)
    // Use a quarter-circle-like arc for a pan head look.
    rotate_extrude(convexity=10)
      polygon(points=
        concat(
          [[0, head_skirt_h], [r, head_skirt_h]],  // base of crown
          [ for (i=[0:24])
              let(t=i/24)
              // arc: x decreases from r to 0, z increases from head_skirt_h to head_h
              [ r*(1 - t*t), head_skirt_h + head_top_crown_h*(1 - (1-t)*(1-t)) ]
          ],
          [[0, head_h], [0, head_skirt_h]]         // close to axis
        )
      );
  }
}

module phillips_recess() {
  // Cut from top down; centered on axis
  z_center = z_head_top - drive_depth/2;

  translate([0,0,z_center])
    union() {
      cube([drive_d, drive_arm_w, drive_depth + 2*overlap], center=true);
      cube([drive_arm_w, drive_d, drive_depth + 2*overlap], center=true);
    }
}

module threaded_shank() {
  // Approximate external thread as a helical ridge on a minor cylinder.
  // Major diameter remains shank_d (minor is reduced by 2*thread_h).
  major_r = shank_d/2;
  minor_r = major_r - thread_h;

  // Threaded region
  z_thread_top = z_shank_top - thread_start_clear;
  z_thread_bot = z_shank_bot + thread_end_clear;
  thread_len   = z_thread_top - z_thread_bot;

  // Ensure non-negative
  thread_len_ok = thread_len > 0 ? thread_len : 0;

  union() {
    // Minor cylinder for core (full length)
    translate([0,0,(z_shank_top + z_shank_bot)/2])
      cylinder(h=length + overlap, r=minor_r, center=true);

    // Helical ridge (only if there is room)
    if (thread_len_ok > 0.01) {
      turns = thread_len_ok / pitch;
      // Place ridge so it spans exactly the threaded region
      translate([0,0,z_thread_bot - overlap/2])
        linear_extrude(height=thread_len_ok + overlap, twist=turns*360, slices=max(ceil(turns*40), 40), convexity=10)
          translate([minor_r, 0, 0])
            square([thread_h, thread_flat], center=false);
    }

    // Under-head unthreaded major cylinder (short) to look like a proper runout
    // This also guarantees a clean connection to the head.
    translate([0,0,(z_shank_top + (z_shank_top - thread_start_clear))/2])
      cylinder(h=thread_start_clear + overlap, r=major_r, center=true);

    // Tip unthreaded major cylinder (short) before chamfer
    translate([0,0,((z_shank_bot + thread_end_clear) + z_shank_bot)/2])
      cylinder(h=thread_end_clear + overlap, r=major_r, center=true);
  }
}

module tip_chamfer() {
  major_r = shank_d/2;
  r2 = major_r - tip_minor_reduction;

  translate([0,0,z_shank_bot + tip_chamfer_h/2 + overlap/2])
    cylinder(h=tip_chamfer_h + overlap, r1=major_r, r2=r2, center=true);
}

module screw_solid() {
  union() {
    // Head
    pan_head_solid();

    // Shank (threaded) connected at Z=0
    threaded_shank();

    // Tip chamfer connected at end
    tip_chamfer();
  }
}

difference() {
  screw_solid();
  // Drive feature from top
  phillips_recess();
}