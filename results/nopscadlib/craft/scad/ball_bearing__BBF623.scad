// Flanged ball bearing (ONE connected solid) with visible inner/outer races + balls
// Target: 3.0mm bore, 10.0mm OD, 4.0mm width, 11.5mm flange OD

$fn = 160;

// Parameters
bore_diameter_mm   = 3.0;   //[1.5:6.0:0.1]
outer_diameter_mm  = 10.0;  //[5.0:20.0:0.1]
width_mm           = 4.0;   //[2.0:8.0:0.1]
flange_diameter_mm = 11.5;  //[5.75:23.0:0.1]
flange_width_mm    = 1.0;   //[0.5:2.0:0.1]

// Visual/detail parameters (kept small so dimensions remain correct)
ball_diameter_mm   = 1.5;   //[0.8:3.0:0.1]
ball_count         = 8;     //[5:16]
race_depth_mm      = 0.35;  //[0.2:0.8:0.05]
race_band_mm       = 1.2;   //[0.6:2.5:0.05]
bridge_mm          = 0.25;  //[0.1:0.6:0.05]  // tiny connector so balls connect to rings
eps_mm             = 0.02;  //[0.01:0.1:0.01]

// Derived radii
R_bore   = bore_diameter_mm/2;
R_outer  = outer_diameter_mm/2;
R_flange = flange_diameter_mm/2;

// Choose a realistic inner-ring OD while keeping enough space for balls/races
ball_r = ball_diameter_mm/2;

// Ensure there is room between inner ring OD and outer ring ID for balls + grooves
min_gap = 2*ball_r + 2*race_depth_mm + 0.25; // clearance so grooves don't break through
R_inner_ring_od = min(R_outer - min_gap, R_bore + 1.6);
R_inner_ring_od = max(R_inner_ring_od, R_bore + 1.2);

// Ball path radius between rings
ball_path_r = (R_inner_ring_od + R_outer)/2;

// Clamp groove depth so it doesn't break through either ring
max_depth = (R_outer - R_inner_ring_od)/2 - 0.12;
race_depth = min(race_depth_mm, max_depth);
race_band  = min(race_band_mm, width_mm - 0.4);

// Helpers
module ring(r_in, r_out, h) {
  difference() {
    cylinder(r=r_out, h=h, center=true);
    cylinder(r=r_in,  h=h + 2*eps_mm, center=true);
  }
}

module race_groove_band(r_center, depth, band_h) {
  // Subtractive torus segment limited to a band around the mid-plane
  intersection() {
    rotate_extrude(convexity=10)
      translate([r_center, 0, 0])
        circle(r=depth, $fn=72);
    cube([2*(R_flange+2), 2*(R_flange+2), band_h], center=true);
  }
}

module balls_with_bridges(n, r_path, ball_r, bridge) {
  // Bridges connect balls to BOTH rings so the whole model is ONE connected solid
  for (i = [0:n-1]) {
    ang = i * 360 / n;
    rotate([0,0,ang]) {
      // Ball
      translate([r_path, 0, 0]) sphere(r=ball_r, $fn=64);

      // Bridge to outer ring (overlaps into outer ring by ~bridge)
      translate([r_path + ball_r - bridge/2, 0, 0])
        cube([bridge, ball_r*0.95, ball_r*0.95], center=true);

      // Bridge to inner ring (overlaps into inner ring by ~bridge)
      translate([r_path - ball_r + bridge/2, 0, 0])
        cube([bridge, ball_r*0.95, ball_r*0.95], center=true);
    }
  }
}

module flanged_bearing() {
  union() {
    // OUTER RING + FLANGE (as a ring, not a solid plug)
    difference() {
      union() {
        // Outer ring body
        ring(R_inner_ring_od, R_outer, width_mm);

        // Flange on +Z face, connected with slight overlap
        translate([0, 0, width_mm/2 + flange_width_mm/2 - eps_mm])
          ring(R_inner_ring_od, R_flange, flange_width_mm);
      }

      // Race groove on outer ring (subtractive)
      race_groove_band(ball_path_r + 0.10, race_depth, race_band);
    }

    // INNER RING (separate ring, but connected via ball bridges)
    difference() {
      ring(R_bore, R_inner_ring_od, width_mm);

      // Race groove on inner ring (subtractive)
      race_groove_band(ball_path_r - 0.10, race_depth, race_band);
    }

    // BALLS (connected to both rings via tiny bridges)
    balls_with_bridges(ball_count, ball_path_r, ball_r, bridge_mm);
  }
}

flanged_bearing();