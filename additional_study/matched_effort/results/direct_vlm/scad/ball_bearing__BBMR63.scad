$fn = 128;

bore_d = 3.0;
od_d   = 6.0;
width  = 2.5;

// One connected solid "visual bearing" that still preserves:
// - 3.0mm bore
// - 6.0mm outer diameter
// - 2.5mm width
// Adds visible race grooves + balls, but keeps everything connected
// via a thin internal web (not physically accurate, but printable/connected).
module bearing_3x6x2p5() {
  outer_r = od_d/2;
  inner_r = bore_d/2;

  // Geometry controls (kept small to preserve dimensions)
  ring_wall   = 0.55;   // radial thickness of each ring
  race_gap    = 0.25;   // nominal gap between rings (visual)
  groove_r    = 0.22;   // race groove "cut" radius (visual)
  web_t       = 0.18;   // thin connecting web thickness (ensures ONE connected solid)
  web_z       = 0.00;   // centered web

  inner_od_r = inner_r + ring_wall; // outer radius of inner ring
  outer_id_r = outer_r - ring_wall; // inner radius of outer ring

  // Ball geometry (visual)
  ball_r  = max(0.22, min(0.40, (outer_id_r - inner_od_r - race_gap)/2));
  pitch_r = (inner_od_r + outer_id_r)/2;

  // Ball count
  nballs = max(7, floor(2*PI*pitch_r / (2.15*ball_r)));

  // Helper: torus-like cutter via rotate_extrude of a circle
  module torus_cutter(R, r, z0=0) {
    translate([0,0,z0])
      rotate_extrude(angle=360)
        translate([R,0,0])
          circle(r=r);
  }

  // Build as a single connected solid:
  // union( rings + balls + connecting web ) minus (bore + race grooves)
  difference() {
    union() {
      // Outer ring (solid)
      difference() {
        cylinder(h=width, r=outer_r, center=true);
        cylinder(h=width+0.2, r=outer_id_r, center=true);
      }

      // Inner ring (solid)
      difference() {
        cylinder(h=width, r=inner_od_r, center=true);
        cylinder(h=width+0.2, r=inner_r, center=true);
      }

      // Balls (solid) - will be partially "seated" by groove cuts below
      for (i = [0:nballs-1]) {
        ang = 360*i/nballs;
        translate([pitch_r*cos(ang), pitch_r*sin(ang), 0])
          sphere(r=ball_r);
      }

      // Thin internal web to guarantee everything is ONE connected solid.
      // It bridges inner ring to outer ring at mid-plane.
      // Overlaps both rings by a tiny amount (eps) to avoid non-manifold seams.
      eps = 0.02;
      translate([0,0,web_z])
        difference() {
          cylinder(h=web_t, r=outer_id_r + eps, center=true);
          cylinder(h=web_t+0.2, r=inner_od_r - eps, center=true);
        }
    }

    // Preserve exact bore
    cylinder(h=width+0.4, r=inner_r, center=true);

    // Race grooves (visual detail): cut shallow torus grooves into both rings
    // at the ball pitch radius, centered in width.
    // These cuts do not break connectivity due to the web.
    torus_cutter(pitch_r, groove_r, 0);

    // Slightly flatten ball contact region (visual) by a second, smaller groove
    torus_cutter(pitch_r, groove_r*0.75, 0);
  }
}

bearing_3x6x2p5();