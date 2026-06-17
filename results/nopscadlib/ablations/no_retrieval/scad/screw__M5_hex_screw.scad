$fn = 96;

// Parameters (mm)
shank_d = 5.0;          // nominal diameter
screw_L = 10.0;         // length under head
head_af = 9.2;          // across flats
head_h = 3.65;          // head height

// Thread (visual approximation)
pitch = 0.8;            // M5 coarse
thread_depth = 0.25;    // radial depth (visual)
thread_L = screw_L;     // threaded length (set to full length)
thread_runout_L = 1.0;  // smooth runout near head

// Details
overlap = 0.25;         // small overlap to ensure watertight union
head_chamfer = 0.6;
tip_chamfer = 0.8;
under_head_fillet_r = 0.6;

// Derived
head_R = head_af / sqrt(3); // circumradius for hex from across-flats
z_head_top = head_h;
z_head_bot = 0;
z_shank_top = z_head_bot;
z_shank_bot = z_head_bot - screw_L;

// Hex head profile (across flats = head_af)
module hex_head_profile(af) {
  polygon(points=[
    [af/sqrt(3), 0],
    [af/(2*sqrt(3)), af/2],
    [-af/(2*sqrt(3)), af/2],
    [-af/sqrt(3), 0],
    [-af/(2*sqrt(3)), -af/2],
    [af/(2*sqrt(3)), -af/2]
  ]);
}

module hex_head() {
  // Main hex prism
  linear_extrude(height=head_h, center=false)
    hex_head_profile(head_af);

  // Top chamfer (subtract-like look via added frustum is not needed; keep solid)
  // Add a small frustum to soften the top edge while staying connected
  translate([0,0,z_head_top - head_chamfer])
    cylinder(h=head_chamfer + overlap, r1=head_R, r2=max(head_R - head_chamfer, 0.01), center=false);
}

module under_head_fillet() {
  // Quarter-round fillet between head underside and shank
  // Place so it touches z=0 plane and the shank radius
  translate([0,0,z_head_bot + overlap])
    rotate_extrude(angle=360)
      translate([shank_d/2 + under_head_fillet_r, 0, 0])
        circle(r=under_head_fillet_r, $fn=64);
}

module shank_core() {
  // Smooth core cylinder (minor diameter) for threads to sit on
  // Use minor radius so thread ridges add up to nominal diameter
  minor_r = max(shank_d/2 - thread_depth, 0.01);
  translate([0,0,z_shank_bot - overlap])
    cylinder(h=screw_L + 2*overlap, r=minor_r, center=false);
}

module tip_chamfer_shape() {
  // Chamfer at the tip (bottom end)
  // Add a small frustum that reaches the minor radius at the very end
  minor_r = max(shank_d/2 - thread_depth, 0.01);
  translate([0,0,z_shank_bot])
    cylinder(h=tip_chamfer, r1=minor_r, r2=max(minor_r - tip_chamfer, 0.01), center=false);
}

module helical_thread(r_minor, depth, pitch, len, z0) {
  // Simple helical ridge using linear_extrude with twist.
  // Cross-section is a small triangle placed at r_minor.
  turns = len / pitch;
  twist_deg = -360 * turns;

  translate([0,0,z0])
    linear_extrude(height=len, twist=twist_deg, slices=max(ceil(turns*24), 24), center=false, convexity=10)
      translate([r_minor, 0, 0])
        polygon(points=[
          [0, -pitch*0.22],
          [depth, 0],
          [0,  pitch*0.22]
        ]);
}

module threads() {
  r_minor = max(shank_d/2 - thread_depth, 0.01);

  // Runout near head: keep first part smooth (no thread) for thread_runout_L
  z_thread_start = z_shank_top - (thread_L - thread_runout_L);
  z_thread_end   = z_shank_top;

  // Full-length thread down to tip, leaving runout near head
  // Threaded region: from z_shank_bot to z_thread_start
  threaded_len = max((z_thread_start - z_shank_bot), 0);

  if (threaded_len > 0.01)
    helical_thread(r_minor=r_minor, depth=thread_depth, pitch=pitch, len=threaded_len, z0=z_shank_bot);

  // Add a short tapered runout ridge to blend into smooth shank near head
  // (approximate by reducing depth linearly with a few stacked helices)
  if (thread_runout_L > 0.01) {
    steps = 6;
    for (i=[0:steps-1]) {
      t0 = i/steps;
      t1 = (i+1)/steps;
      z0 = z_thread_start + t0*thread_runout_L;
      segL = (t1-t0)*thread_runout_L + overlap;
      d = thread_depth * (1 - t0); // decreasing depth toward head
      if (d > 0.01)
        helical_thread(r_minor=r_minor, depth=d, pitch=pitch, len=segL, z0=z0);
    }
  }
}

module smooth_shank_runout() {
  // Smooth cylinder at nominal diameter for the runout region under head
  // Ensures a clean transition and solid connectivity
  translate([0,0,z_shank_top - thread_runout_L - overlap])
    cylinder(h=thread_runout_L + 2*overlap, r=shank_d/2, center=false);
}

module screw() {
  union() {
    // Head (z: 0..head_h)
    hex_head();

    // Under-head fillet (touches both head underside and shank)
    under_head_fillet();

    // Shank core (minor diameter) (z: -screw_L..0)
    shank_core();

    // Smooth runout near head at nominal diameter (z: -thread_runout_L..0)
    smooth_shank_runout();

    // Threads (helical ridges) along shank
    threads();

    // Tip chamfer (at bottom)
    tip_chamfer_shape();
  }
}

screw();