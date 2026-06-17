// Flanged ball bearing: 3.0mm bore, 8.0mm OD, 3.0mm width, 9.5mm flange OD
// One connected solid; visible through-bore; recognizable inner/outer race + ball groove + cage pockets.

$fn = 128;

// Parameters
bore_d   = 3.0;   //[1.5:6.0:0.1]
od_d     = 8.0;   //[4.0:16.0:0.1]
width_w  = 3.0;   //[1.5:6.0:0.1]
flange_d = 9.5;   //[6.0:19.0:0.1]
flange_t = 0.6;   //[0.3:1.2:0.05]

race_radial_t   = 0.8;  //[0.4:1.6:0.05]
race_axial_step = 0.3;  //[0.15:0.6:0.05]
chamfer_c       = 0.2;  //[0.1:0.5:0.05]

ball_d     = 0.9; //[0.5:1.8:0.05]
ball_count = 8;   //[4:16:1]

seal_t  = 0.25; //[0.15:0.6:0.05]
overlap = 0.2;  //[0.05:1.0:0.05]

// Derived
body_r   = od_d/2;
bore_r   = bore_d/2;
flange_r = flange_d/2;

inner_race_r = bore_r + race_radial_t;
outer_race_r = body_r - race_radial_t;

ball_path_r = (inner_race_r + outer_race_r)/2;

// Keep balls inside the body envelope
ball_path_r = min(ball_path_r, body_r - ball_d/2 - 0.15);
ball_path_r = max(ball_path_r, bore_r + ball_d/2 + 0.15);

// Groove (torus) radius for raceway impression
groove_r = ball_d*0.55;

// Cage ring dimensions (kept within bearing body)
cage_thick = max(0.35, ball_d*0.45);
cage_r_out = min(body_r - 0.25, ball_path_r + ball_d/2 + cage_thick);
cage_r_in  = max(bore_r + 0.25, ball_path_r - ball_d/2 - cage_thick);
cage_h     = min(width_w - 2*seal_t - 0.2, ball_d + 0.25);
cage_h     = max(cage_h, ball_d*0.9);

// Helpers
module torus(R, r) {
  rotate_extrude(convexity=10)
    translate([R, 0, 0])
      circle(r=r, $fn=64);
}

module chamfer_ring(z, r_outer, r_inner, c) {
  // subtractive chamfer ring at face z (centered model)
  translate([0,0,z])
    difference() {
      cylinder(h=c + 2*overlap, r=r_outer + overlap, center=true);
      cylinder(h=c + 4*overlap, r=r_inner - overlap, center=true);
      // cone to create chamfer
      cylinder(h=c + 2*overlap, r1=r_outer + overlap, r2=r_outer - c, center=true);
    }
}

module bearing_solid_with_flange() {
  union() {
    // Main body
    cylinder(r=body_r, h=width_w, center=true);

    // Flange on +Z face, connected with slight overlap
    translate([0,0, width_w/2 - flange_t/2 + overlap/2])
      cylinder(r=flange_r, h=flange_t + overlap, center=true);
  }
}

module bore_through() {
  cylinder(r=bore_r, h=width_w + flange_t + 6*overlap, center=true);
}

module raceway_grooves() {
  // Subtractive grooves to suggest ball tracks (inner + outer)
  // Positioned at mid-plane so they are visible in section and edges.
  union() {
    // Outer race groove
    torus(ball_path_r, groove_r);

    // Slightly offset second groove to hint inner/outer separation
    // (still subtractive, creates a more "bearing-like" profile)
    translate([0,0,0])
      torus(ball_path_r, groove_r*0.75);
  }
}

module inner_outer_race_steps() {
  // Additive steps to show inner/outer race separation (still one solid overall)
  union() {
    // Inner race ring (around bore)
    cylinder(r=inner_race_r, h=width_w - 2*race_axial_step, center=true);

    // Outer race ring (near OD)
    difference() {
      cylinder(r=body_r, h=width_w - 2*race_axial_step, center=true);
      cylinder(r=outer_race_r, h=width_w - 2*race_axial_step + 2*overlap, center=true);
    }
  }
}

module seals() {
  // Thin shields near faces (additive)
  union() {
    translate([0,0, width_w/2 - seal_t/2 - chamfer_c/2])
      cylinder(r=body_r - chamfer_c, h=seal_t, center=true);

    translate([0,0,-width_w/2 + seal_t/2 + chamfer_c/2])
      cylinder(r=body_r - chamfer_c, h=seal_t, center=true);
  }
}

module cage_with_pockets() {
  // Cage ring with ball pockets (additive, connected to races via overlap)
  difference() {
    cylinder(r=cage_r_out, h=cage_h, center=true);
    cylinder(r=cage_r_in,  h=cage_h + 2*overlap, center=true);

    // Ball pockets
    for (i = [0:ball_count-1]) {
      rotate([0,0,i*360/ball_count])
        translate([ball_path_r, 0, 0])
          sphere(r=ball_d/2 + 0.08, $fn=48);
    }
  }
}

module balls() {
  // Add balls (additive) so they are visible; they intersect grooves/cage slightly to ensure connectivity.
  for (i = [0:ball_count-1]) {
    rotate([0,0,i*360/ball_count])
      translate([ball_path_r, 0, 0])
        sphere(r=ball_d/2, $fn=48);
  }
}

module face_chamfers_subtractive() {
  // Subtractive chamfers on main body OD (not flange OD)
  union() {
    // Top face chamfer on body OD
    translate([0,0, width_w/2 - chamfer_c/2])
      cylinder(h=chamfer_c + 2*overlap, r1=body_r + overlap, r2=body_r - chamfer_c, center=true);

    // Bottom face chamfer on body OD
    translate([0,0,-width_w/2 + chamfer_c/2])
      cylinder(h=chamfer_c + 2*overlap, r1=body_r - chamfer_c, r2=body_r + overlap, center=true);
  }
}

// Final model (one connected solid)
difference() {
  union() {
    bearing_solid_with_flange();
    inner_outer_race_steps();
    seals();
    cage_with_pockets();
    balls();
  }

  // Ensure visible through-bore
  bore_through();

  // Raceway grooves (subtractive)
  raceway_grooves();

  // Face chamfers (subtractive)
  face_chamfers_subtractive();
}