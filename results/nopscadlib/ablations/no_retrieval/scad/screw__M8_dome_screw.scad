// Dome head screw: 8.0mm major (thread) diameter, 14.0mm head diameter,
// head height 4.4mm, 10mm under-head length.
// One connected solid, with visible helical threads and an INTERNAL hex socket drive.

$fn = 128;

// -------------------- Parameters --------------------
major_d   = 8.0;     // mm (thread major diameter)
shank_len = 10.0;    // mm (under-head length)
head_d    = 14.0;    // mm
head_h    = 4.4;     // mm

// Thread (visual/printable approximation)
thread_pitch = 1.25; // mm
thread_depth = 0.60; // mm radial depth (major->minor)
thread_len   = 10.0; // mm (threaded length along shank)
tip_chamfer_h = 0.8; // mm

// Underhead blend
underhead_fillet_r = 0.8; // mm

// Drive (internal hex socket)
drive_hex_flat  = 6.0;  // across flats (mm)
drive_depth     = 3.0;  // mm
drive_clearance = 0.2;  // mm

eps = 0.03;

// Dome shaping: spherical cap meeting head_d at z=0 and reaching head_h at top
head_dome_r = (pow(head_d/2,2) + pow(head_h,2)) / (2*head_h);

// -------------------- Helpers --------------------
function clamp(x,a,b) = x < a ? a : (x > b ? b : x);

module hex2d(af=6) {
  // Regular hex with across-flats = af
  r = af / sqrt(3);
  polygon([for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

// -------------------- Geometry --------------------
module shank_minor_core(L) {
  // Core at MINOR diameter so threads are clearly visible as raised ridges.
  minor_d = major_d - 2*thread_depth;
  translate([0,0,-L/2])
    cylinder(h=L, r=minor_d/2, center=true);
}

module tip_chamfer_on_minor(L) {
  // Conical tip on the minor core (keeps end neat while threads remain visible)
  minor_d = major_d - 2*thread_depth;
  z0 = -L;
  translate([0,0,z0 + tip_chamfer_h/2])
    cylinder(h=tip_chamfer_h, r1=minor_d/2, r2=0, center=true);
}

module underhead_fillet() {
  // Small fillet between shank and head underside
  rotate_extrude(convexity=10)
    translate([major_d/2 - underhead_fillet_r, 0, 0])
      circle(r=underhead_fillet_r, $fn=64);
}

module dome_head_solid() {
  // Spherical cap from z=0..head_h with base diameter head_d
  zc = -(head_dome_r - head_h);
  intersection() {
    translate([0,0,zc]) sphere(r=head_dome_r, $fn=180);
    translate([0,0,head_h/2]) cylinder(h=head_h, r=head_d/2, center=true);
  }
}

module drive_recess() {
  // Internal hex socket cut from top
  translate([0,0,head_h - drive_depth/2 + eps])
    linear_extrude(height=drive_depth + 2*eps, center=true, convexity=10)
      offset(r=drive_clearance)
        hex2d(drive_hex_flat);
}

module helical_thread(L) {
  // Raised helical ridge around the minor core up to major diameter.
  major_r = major_d/2;
  minor_r = major_r - thread_depth;

  // Thread runs from z=-L .. 0
  translate([0,0,-L])
    linear_extrude(
      height=L,
      twist=360*L/thread_pitch,
      slices=max(ceil(36*L/thread_pitch), 80),
      convexity=10
    )
      // 2D profile: triangular ridge attached to the minor radius
      polygon(points=[
        [minor_r, -thread_pitch*0.28],
        [major_r,  0],
        [minor_r,  thread_pitch*0.28]
      ]);
}

module screw_solid() {
  L = clamp(thread_len, 0, shank_len);

  difference() {
    union() {
      // Threaded shank: minor core + raised helical thread (connected)
      union() {
        shank_minor_core(shank_len);
        tip_chamfer_on_minor(shank_len);
        helical_thread(L);
      }

      // Underhead fillet (touches shank and head)
      underhead_fillet();

      // Dome head (base at z=0)
      dome_head_solid();
    }

    // Internal drive recess
    drive_recess();
  }
}

// -------------------- Output --------------------
screw_solid();