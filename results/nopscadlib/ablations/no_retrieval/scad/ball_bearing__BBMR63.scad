// Ball bearing: 3.0mm bore, 6.0mm OD, 2.5mm width
// One connected solid with visible balls/cage and verifiable bore/OD/width

$fn = 160;

// ---- Target dimensions ----
bore_d  = 3.0;
outer_d = 6.0;
width   = 2.5;

// ---- Feature tuning (kept within target envelope) ----
ring_radial_thk = 0.70;   // ring wall thickness (radial)
ball_d          = 0.80;
ball_count      = 8;

cage_thk        = 0.55;   // axial thickness of cage (visible in side view)
cage_web        = 0.22;   // radial web thickness around ball pockets

shield_thk      = 0.18;   // thin shields to show bore in top/bottom views
shield_gap      = 0.10;   // radial clearance to inner ring OD

groove_r_factor = 0.55;   // race groove radius relative to ball radius
chamfer_r       = 0.10;

overlap         = 0.06;   // small overlap to guarantee connectivity

// ---- Derived ----
bore_r  = bore_d/2;
outer_r = outer_d/2;

inner_ring_or = bore_r + ring_radial_thk;
outer_ring_ir = outer_r - ring_radial_thk;

ball_r = ball_d/2;

// Ball path radius (center of balls) - centered between ring raceways
ball_path_r = (inner_ring_or + outer_ring_ir)/2;

// ---- Helpers ----
module cyl(r, h) { cylinder(r=r, h=h, center=true); }

module torus(R, r) {
  rotate_extrude(convexity=10)
    translate([R, 0, 0])
      circle(r=r, $fn=max(36, $fn/3));
}

// ---- Rings with race grooves and chamfers ----
module outer_ring() {
  difference() {
    cyl(outer_r, width);
    cyl(outer_ring_ir, width + 2*overlap);
  }
}

module inner_ring() {
  difference() {
    cyl(inner_ring_or, width);
    cyl(bore_r, width + 2*overlap);
  }
}

module outer_ring_detailed() {
  groove_r = ball_r * groove_r_factor;
  difference() {
    outer_ring();
    // race groove (continuous)
    torus(ball_path_r, groove_r);
    // outer edge chamfers (top/bottom)
    translate([0,0, width/2]) torus(outer_r - chamfer_r, chamfer_r);
    translate([0,0,-width/2]) torus(outer_r - chamfer_r, chamfer_r);
  }
}

module inner_ring_detailed() {
  groove_r = ball_r * groove_r_factor;
  difference() {
    inner_ring();
    // race groove (continuous)
    torus(ball_path_r, groove_r);
    // bore edge chamfers (top/bottom)
    translate([0,0, width/2]) torus(bore_r + chamfer_r, chamfer_r);
    translate([0,0,-width/2]) torus(bore_r + chamfer_r, chamfer_r);
  }
}

// ---- Balls ----
module balls() {
  for (i = [0:ball_count-1]) {
    rotate([0,0, i*360/ball_count])
      translate([ball_path_r, 0, 0])
        sphere(r=ball_r, $fn=max(48, $fn/2));
  }
}

// ---- Cage (ring with ball pockets) ----
module cage() {
  // Cage ring bounds around ball centers; keep it visible and connected
  cage_or = ball_path_r + ball_r + cage_web;
  cage_ir = ball_path_r - ball_r - cage_web;

  // Ensure cage stays within bearing envelope
  cage_or = min(cage_or, outer_ring_ir - overlap);
  cage_ir = max(cage_ir, inner_ring_or + overlap);

  difference() {
    // Overlap slightly into rings/balls so the whole model is one connected solid
    cyl(cage_or, cage_thk + 2*overlap);
    cyl(cage_ir, cage_thk + 2*overlap + 2*overlap);

    // Ball pockets (through the cage thickness)
    for (i = [0:ball_count-1]) {
      rotate([0,0, i*360/ball_count])
        translate([ball_path_r, 0, 0])
          cylinder(r=ball_r*1.10, h=cage_thk + 6*overlap, center=true, $fn=max(48, $fn/2));
    }
  }
}

// ---- Shields (thin discs with center opening so bore is visible in top/bottom views) ----
module shield(zpos) {
  shield_r = outer_r - chamfer_r*0.6;          // within OD
  hole_r   = inner_ring_or + shield_gap;       // clears inner ring OD

  translate([0,0,zpos])
    difference() {
      // Slight overlap into outer ring so it fuses
      cyl(shield_r, shield_thk + overlap);
      cyl(hole_r,   shield_thk + 2*overlap);
    }
}

module shields() {
  // Place shields just inside the bearing faces (computed from width)
  z = width/2 - shield_thk/2 - overlap*0.25;
  shield( z);
  shield(-z);
}

// ---- Final: one connected solid ----
union() {
  outer_ring_detailed();
  inner_ring_detailed();

  // Balls + cage (unioned; cage overlaps slightly so everything is connected)
  balls();
  cage();

  // Shields (unioned; overlap into outer ring)
  shields();
}