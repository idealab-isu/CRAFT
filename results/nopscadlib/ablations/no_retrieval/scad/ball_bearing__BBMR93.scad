// Ball bearing: 3.0mm bore, 9.0mm OD, 4.0mm width
// One connected solid with visible balls and race grooves.

$fn = 128;

// Target dimensions
bore_d  = 3.0;
outer_d = 9.0;
width_w = 4.0;

// Bearing feature parameters (chosen to fit within 3x9x4 envelope)
ball_d        = 1.2;
ball_count    = 8;
ball_pitch_d  = 6.0;     // center circle for balls
groove_r      = 0.55;    // race groove radius (visual)
race_z_offset = 0.0;     // centered

// Ring thicknesses (radial)
inner_ring_radial_thk = 1.0;  // makes inner ring OD = bore/2 + thk
outer_ring_radial_thk = 1.0;  // makes outer ring ID = outer/2 - thk

// Connectivity / overlap
overlap_eps = 0.25;      // small overlap to ensure single connected solid
cage_thk    = 0.7;       // thin cage band
cage_radial = 0.35;      // cage radial thickness around ball pitch
cage_clear  = 0.10;      // clearance around balls in cage pockets

// Derived radii
bore_r  = bore_d/2;
outer_r = outer_d/2;

inner_ring_outer_r = bore_r + inner_ring_radial_thk;
outer_ring_inner_r = outer_r - outer_ring_radial_thk;

ball_pitch_r = ball_pitch_d/2;

// Sanity clamp to keep geometry inside envelope
// (If parameters are edited, keep pitch between rings)
ball_pitch_r_clamped = min(max(ball_pitch_r, inner_ring_outer_r + ball_d/2 + 0.15),
                           outer_ring_inner_r - ball_d/2 - 0.15);

module ring(r_outer, r_inner, h) {
  difference() {
    cylinder(r=r_outer, h=h, center=true);
    cylinder(r=r_inner, h=h + 2*overlap_eps, center=true);
  }
}

module race_groove_torus(r_center, r_groove) {
  // Torus centered on Z=0; subtract from rings to form race grooves
  rotate_extrude()
    translate([r_center, 0, 0])
      circle(r=r_groove);
}

module ball() {
  sphere(r=ball_d/2);
}

module balls() {
  for (i = [0:ball_count-1]) {
    rotate([0,0,i*360/ball_count])
      translate([ball_pitch_r_clamped, 0, race_z_offset])
        ball();
  }
}

module cage() {
  // A thin band that overlaps balls slightly so everything is one connected solid.
  // Pockets are cut for visual separation.
  cage_r_outer = ball_pitch_r_clamped + ball_d/2 + cage_radial;
  cage_r_inner = ball_pitch_r_clamped - (ball_d/2 + cage_radial);

  difference() {
    // Band (slightly thicker in Z to overlap balls)
    cylinder(r=cage_r_outer, h=cage_thk, center=true);
    cylinder(r=cage_r_inner, h=cage_thk + 2*overlap_eps, center=true);

    // Ball pockets
    for (i = [0:ball_count-1]) {
      rotate([0,0,i*360/ball_count])
        translate([ball_pitch_r_clamped, 0, 0])
          sphere(r=ball_d/2 + cage_clear);
    }
  }
}

module inner_ring() {
  // Inner ring with groove
  difference() {
    ring(inner_ring_outer_r, bore_r, width_w);
    // Groove centered at ball pitch; slightly overlaps ring volume
    race_groove_torus(ball_pitch_r_clamped, groove_r);
  }
}

module outer_ring() {
  // Outer ring with groove
  difference() {
    ring(outer_r, outer_ring_inner_r, width_w);
    race_groove_torus(ball_pitch_r_clamped, groove_r);
  }
}

module bearing_connected_solid() {
  // Ensure one connected solid by adding a very thin, hidden bridge
  // between inner and outer rings at mid-plane (inside race area).
  // This keeps the model manifold/connected even if balls/cage are edited.
  bridge_r1 = inner_ring_outer_r - overlap_eps;
  bridge_r2 = outer_ring_inner_r + overlap_eps;

  union() {
    outer_ring();
    inner_ring();
    balls();
    cage();

    // Thin bridge disk in the race gap (overlaps both rings slightly)
    difference() {
      cylinder(r=bridge_r2, h=overlap_eps, center=true);
      cylinder(r=bridge_r1, h=overlap_eps + 2*overlap_eps, center=true);
    }
  }
}

bearing_connected_solid();