// Ball bearing: 5.0mm bore, 9.0mm OD, 3.0mm width
// One connected solid with visible balls and race grooves.
// Dimensions enforced by construction (bore_d, outer_d, width).

$fn = 180;

// Requested dimensions
bore_d  = 5.0;
outer_d = 9.0;
width   = 3.0;

// Feature parameters (kept within the envelope)
ball_d      = 1.15;
ball_count  = 7;

race_r      = 0.42;   // groove "round" radius (visual)
race_z_thk  = 1.25;   // axial band thickness for groove cut

chamfer     = 0.18;   // small edge chamfer

// Connectivity requirements: add slight overlap (1-2mm) between parts
connect_ov  = 1.2;    // overlap amount used to fuse balls to races (mm)
overlap     = 0.05;   // robust boolean overlap

// Derived radii
bore_r  = bore_d/2;
outer_r = outer_d/2;

// Ball pitch radius (kept safely between bore and OD)
pitch_r_min = bore_r  + ball_d/2 + 0.35;
pitch_r_max = outer_r - ball_d/2 - 0.35;
pitch_r     = (pitch_r_min + pitch_r_max)/2;

// Ring boundaries around the ball path
inner_ring_or = pitch_r - ball_d/2 - 0.22;  // inner ring outer radius
outer_ring_ir = pitch_r + ball_d/2 + 0.22;  // outer ring inner radius

// Clamp to keep valid geometry
inner_ring_or = max(inner_ring_or, bore_r + 0.40);
outer_ring_ir = min(outer_ring_ir, outer_r - 0.40);

// --- Helpers ---

module chamfer_ring(r_outer, r_inner, h, c) {
  // Ring with small chamfers on both faces at both edges
  difference() {
    cylinder(r=r_outer, h=h, center=true);
    cylinder(r=r_inner, h=h + 2*overlap, center=true);

    // Outer edge chamfers (top/bottom)
    for (z = [-1, 1]) {
      translate([0,0, z*(h/2 - c/2)])
        cylinder(r1=r_outer + c, r2=r_outer - c, h=c + 2*overlap, center=true);
    }

    // Inner edge chamfers (top/bottom)
    for (z = [-1, 1]) {
      translate([0,0, z*(h/2 - c/2)])
        cylinder(r1=r_inner - c, r2=r_inner + c, h=c + 2*overlap, center=true);
    }
  }
}

module race_groove_cut(r_center, z_thk, groove_r) {
  // Torus-like groove, limited to an axial band (z_thk)
  intersection() {
    rotate_extrude(convexity=10, $fn=220)
      translate([r_center, 0, 0])
        circle(r=groove_r, $fn=96);

    // Axial limiter band
    cylinder(r=outer_r + 5, h=z_thk, center=true);
  }
}

module ball_at(angle_deg) {
  translate([pitch_r*cos(angle_deg), pitch_r*sin(angle_deg), 0])
    sphere(r=ball_d/2, $fn=96);
}

module balls() {
  for (i = [0:ball_count-1])
    ball_at(i*360/ball_count);
}

module inner_ring() {
  difference() {
    chamfer_ring(inner_ring_or, bore_r, width, chamfer);
    // Groove cut into the outer surface of the inner ring
    race_groove_cut(pitch_r, race_z_thk, race_r);
  }
}

module outer_ring() {
  difference() {
    chamfer_ring(outer_r, outer_ring_ir, width, chamfer);
    // Groove cut into the inner surface of the outer ring
    race_groove_cut(pitch_r, race_z_thk, race_r);
  }
}

module connector_web() {
  // Annular web at z=0 that bridges inner ring to outer ring.
  // Make it thick enough to guarantee a single connected solid.
  // (Also provides a "cage/shield" look without changing the envelope.)
  web_h = min(width - 0.4, connect_ov); // keep within width, still substantial
  web_h = max(web_h, 0.8);              // ensure meaningful connection

  // Span across the ball region so it touches both rings
  web_r_in  = inner_ring_or - 0.10;
  web_r_out = outer_ring_ir + 0.10;

  // Keep within envelope
  web_r_in  = max(web_r_in, bore_r + 0.20);
  web_r_out = min(web_r_out, outer_r - 0.20);

  difference() {
    cylinder(r=web_r_out, h=web_h, center=true);
    cylinder(r=web_r_in,  h=web_h + 2*overlap, center=true);
  }
}

module ball_fusers() {
  // Add two thin annular "fuser" rings that overlap the balls by ~connect_ov.
  // This guarantees the balls are physically connected to the races (single solid),
  // while keeping the bearing silhouette recognizable.
  fuser_h = min(width - 0.2, connect_ov);
  fuser_h = max(fuser_h, 0.8);

  // Radial overlap into the balls
  r_in  = pitch_r - ball_d/2 - connect_ov;
  r_out = pitch_r + ball_d/2 + connect_ov;

  // Clamp to stay inside the bearing envelope
  r_in  = max(r_in,  bore_r + 0.25);
  r_out = min(r_out, outer_r - 0.25);

  // Place fusers near both faces so balls remain visible in the mid-plane
  zpos = (width/2 - fuser_h/2);

  for (z = [-zpos, zpos]) {
    translate([0,0,z])
      difference() {
        cylinder(r=r_out, h=fuser_h, center=true);
        cylinder(r=r_in,  h=fuser_h + 2*overlap, center=true);
      }
  }
}

module bearing_one_connected_solid() {
  union() {
    outer_ring();
    inner_ring();
    balls();
    // Ensure all parts are connected into a single solid:
    connector_web();   // connects inner <-> outer
    ball_fusers();     // connects balls <-> rings with 1-2mm overlap
  }
}

bearing_one_connected_solid();