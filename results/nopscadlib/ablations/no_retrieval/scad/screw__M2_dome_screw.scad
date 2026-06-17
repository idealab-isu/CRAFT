$fn = 96;

// Requested dimensions (mm)
shank_d = 2.0;
length_under_head = 10.0;
head_d = 3.5;
head_h = 1.3;

// Simple thread look (cosmetic rings; not a true helix)
thread_pitch = 0.4;
thread_len = 9.0;
thread_depth = 0.12;
thread_ridge_w = 0.18;

// Tip
tip_chamfer_h = 0.5;

// Recess (cylindrical; keep small so head stays dome-like)
drive_recess_d = 1.4;
drive_recess_h = 0.7;

// Connectivity / robustness
overlap = 0.05;

// Derived
shank_r = shank_d/2;
head_r  = head_d/2;

// Coordinate convention:
// z=0 at underside of head (bearing surface)
// shank extends to negative z
// head extends to positive z

module shank_body() {
  translate([0,0,-length_under_head/2])
    cylinder(h=length_under_head, r=shank_r, center=true);
}

module tip_cone() {
  // Cone replaces last tip_chamfer_h of the shank
  translate([0,0,-length_under_head + tip_chamfer_h/2])
    cylinder(h=tip_chamfer_h + overlap, r1=shank_r, r2=0, center=true);
}

module cosmetic_threads() {
  // Rings along the threaded portion (from near tip upward)
  // Threaded region ends at z=0 (under head)
  start_z = -thread_len;
  n = max(1, floor(thread_len/thread_pitch));
  for (i = [0:n-1]) {
    zc = start_z + (i+0.5)*thread_pitch;
    translate([0,0,zc])
      cylinder(h=thread_ridge_w, r=shank_r + thread_depth, center=true);
  }
}

module dome_head() {
  // Spherical cap with exact base diameter head_d at z=0 and height head_h at z=head_h
  // Sphere radius R = (a^2 + h^2)/(2h), center at z = h - R
  a = head_r;
  h = head_h;
  R = (a*a + h*h)/(2*h);
  zc = h - R;

  intersection() {
    translate([0,0,zc]) sphere(r=R);
    // Keep only 0..h
    translate([0,0,h/2]) cube([head_d*2, head_d*2, h], center=true);
  }
}

module drive_recess() {
  // Cylindrical recess from top of head downward
  translate([0,0,head_h - drive_recess_h/2])
    cylinder(h=drive_recess_h + overlap, r=drive_recess_d/2, center=true);
}

module screw_solid() {
  union() {
    shank_body();
    // Ensure tip is connected and replaces end
    tip_cone();
    // Cosmetic threads (connected by overlap with shank)
    cosmetic_threads();
    // Head connected at z=0 with slight overlap into shank
    translate([0,0,-overlap]) dome_head();
  }
}

difference() {
  screw_solid();
  drive_recess();
}