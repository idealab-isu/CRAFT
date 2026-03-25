// Parameters
bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
outer_diameter_mm = 9.0; //[4.5:18.0:0.1]
width_mm = 2.5; //[1.25:5.0:0.05]
radial_clearance_mm = 0.15; //[0.05:0.4:0.01]
race_wall_mm = 0.6; //[0.3:1.2:0.05]
shield_thickness_mm = 0.25; //[0.15:0.6:0.01]
shield_radial_gap_mm = 0.2; //[0.05:0.6:0.01]
ball_diameter_mm = 1.0; //[0.6:1.6:0.05]
ball_count = 8; //[6:12:1]
ball_overlap_mm = 0.2; //[0.05:0.5:0.01]
connect_overlap_mm = 0.8; //[0.3:1.5:0.05]

// Extra overlap to guarantee physical attachment (1-2mm as requested)
attach_overlap_mm = 1.2;

// Bearing Ball
module bearing_ball() {
  sphere(r=ball_diameter_mm/2, $fn=32);
}

// Main bearing
module ball_bearing() {

  // Derived radii
  outer_r = outer_diameter_mm/2;
  inner_bore_r = bore_diameter_mm/2;

  // Race ring radii (as in original intent)
  inner_race_outer_r = inner_bore_r + race_wall_mm;
  outer_race_inner_r = outer_r - race_wall_mm;

  // Ball path radius (midway between race ring radii)
  ball_path_r = (inner_race_outer_r + outer_race_inner_r) / 2;

  // Ball pocket (groove) radius used in original code
  groove_r = ball_diameter_mm/2 + ball_overlap_mm;

  // Z placement for split races (ensure overlap so they become one connected solid)
  // Make the two race halves overlap by ~attach_overlap_mm.
  half_gap = max(0, groove_r - attach_overlap_mm/2); // smaller than groove_r => overlap
  z_off = half_gap;

  // Helper: race groove cutter (torus-like via rotate_extrude)
  module groove_cutter(r_at) {
    // Slightly taller than width to ensure clean cut
    scale([1, 1, (width_mm/ball_diameter_mm) * 0.9])
      rotate_extrude($fn=64)
        translate([r_at, 0, 0])
          circle(r=groove_r, $fn=32);
  }

  // One half of the outer race (top or bottom)
  module outer_race_half(zsign=1) {
    translate([0,0,zsign*z_off])
    difference() {
      cylinder(r=outer_r, h=width_mm, center=true, $fn=64);
      cylinder(r=outer_race_inner_r, h=width_mm + 2*connect_overlap_mm, center=true, $fn=64);
      groove_cutter(outer_race_inner_r);
    }
  }

  // One half of the inner race (top or bottom)
  module inner_race_half(zsign=1) {
    translate([0,0,zsign*z_off])
    difference() {
      cylinder(r=inner_race_outer_r, h=width_mm, center=true, $fn=64);
      cylinder(r=inner_bore_r, h=width_mm + 2*connect_overlap_mm, center=true, $fn=64);
      groove_cutter(inner_race_outer_r);
    }
  }

  // Shields (kept, but unioned into the single solid and slightly overlapped into races)
  module shields() {
    for (z = [-1, 1]) {
      // Push shields slightly inward so they intersect the race halves
      zpos = z * (width_mm/2 - shield_thickness_mm/2 - attach_overlap_mm/2);
      translate([0, 0, zpos])
      difference() {
        cylinder(r=outer_r - shield_radial_gap_mm, h=shield_thickness_mm + attach_overlap_mm, center=true, $fn=64);
        cylinder(r=inner_bore_r + shield_radial_gap_mm, h=shield_thickness_mm + attach_overlap_mm + 2*connect_overlap_mm, center=true, $fn=64);
      }
    }
  }

  // Ball "cage" / retainer ring to physically attach balls to the main body
  // (thin ring at ball path radius, intersecting balls by ~attach_overlap_mm)
  module ball_retainer() {
    retainer_th = max(0.6, attach_overlap_mm); // thickness
    retainer_h  = max(0.8, ball_diameter_mm * 0.6);

    difference() {
      cylinder(r=ball_path_r + retainer_th/2, h=retainer_h, center=true, $fn=96);
      cylinder(r=ball_path_r - retainer_th/2, h=retainer_h + 2*connect_overlap_mm, center=true, $fn=96);
    }
  }

  // Balls (now unioned and physically intersecting the retainer and race halves)
  module balls() {
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
        translate([ball_path_r, 0, 0])
          bearing_ball();
    }
  }

  // Single connected solid
  union() {
    // Split races (top/bottom) with intentional overlap so they become one connected solid
    outer_race_half( 1);
    outer_race_half(-1);
    inner_race_half( 1);
    inner_race_half(-1);

    // Retainer connects balls to the bearing body
    ball_retainer();

    // Balls are now part of the union and intersect the retainer (no floating)
    balls();

    // Shields slightly overlap into races to avoid gaps
    shields();
  }
}

// Assembly
ball_bearing();