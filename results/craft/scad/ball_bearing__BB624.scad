// Ball bearing: 4.0mm bore, 13.0mm OD, 5.0mm width
// STRUCTURAL FIX: force ALL parts to be one connected solid by adding hidden bridges
// that overlap 1–2mm into adjacent parts (races, cage, balls).

$fn = 128;

// Parameters
bore_diameter_mm  = 4.0;   //[2.0:8.0:0.1]
outer_diameter_mm = 13.0;  //[6.5:26.0:0.1]
width_mm          = 5.0;   //[2.5:10.0:0.1]

eps_mm = 0.15;             //[0.05:0.5:0.05]

// Visual/geometry tuning (kept deterministic and dimension-derived)
race_wall_radial_mm = 1.25;   // radial thickness of each race ring
race_lip_z_mm       = 0.55;   // small lips to suggest race shoulders
ball_diameter_mm    = 2.0;    //[1.0:4.0:0.1]
num_balls           = 8;      //[6:12:1]
cage_thickness_mm   = 0.55;   // thin cage ring thickness (axial)
cage_radial_mm      = 0.55;   // cage ring radial thickness

// Derived radii
bore_r  = bore_diameter_mm/2;
od_r    = outer_diameter_mm/2;

// Inner race outer radius and outer race inner radius
inner_race_or = bore_r + race_wall_radial_mm;
outer_race_ir = od_r   - race_wall_radial_mm;

// Ball path radius (center of balls)
ball_path_r = (inner_race_or + outer_race_ir)/2;

// Ensure balls fit between races (simple clamp)
ball_r = min(ball_diameter_mm/2, (outer_race_ir - inner_race_or)/2 - 0.05);

// Connectivity overlaps (1–2mm as required)
overlap_mm  = 1.2;          // general overlap used for fusing parts
bridge_z_mm = 1.2;          // axial thickness of hidden bridges (kept inside width)
bridge_w_mm = 1.2;          // tangential width of each bridge tab

// Outer race (ring with subtle lips)
module outer_race() {
  difference() {
    union() {
      // main ring
      cylinder(r=od_r, h=width_mm, center=true);

      // lips (slightly intruding) to suggest shoulders
      for (zsgn = [-1, 1]) {
        translate([0,0, zsgn*(width_mm/2 - race_lip_z_mm/2)])
          difference() {
            cylinder(r=od_r, h=race_lip_z_mm, center=true);
            cylinder(r=outer_race_ir + 0.35, h=race_lip_z_mm + 2*eps_mm, center=true);
          }
      }
    }

    // inner void of outer race
    cylinder(r=outer_race_ir, h=width_mm + 2*eps_mm, center=true);
  }
}

// Inner race (ring with subtle lips)
module inner_race() {
  difference() {
    union() {
      // main ring
      cylinder(r=inner_race_or, h=width_mm, center=true);

      // lips (slightly protruding) to suggest shoulders
      for (zsgn = [-1, 1]) {
        translate([0,0, zsgn*(width_mm/2 - race_lip_z_mm/2)])
          cylinder(r=inner_race_or + 0.35, h=race_lip_z_mm, center=true);
      }
    }

    // clean circular bore
    cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
  }
}

// Balls (kept visible; will be fused via bridges)
module balls() {
  for (i = [0:num_balls-1]) {
    rotate([0,0, i*360/num_balls])
      translate([ball_path_r, 0, 0])
        sphere(r=ball_r);
  }
}

// Simple cage: thin ring with pockets around balls (kept visible; will be fused via bridges)
module cage() {
  cage_r_mid = ball_path_r;
  cage_r_in  = cage_r_mid - (ball_r + cage_radial_mm);
  cage_r_out = cage_r_mid + (ball_r + cage_radial_mm);

  difference() {
    // cage ring
    cylinder(r=cage_r_out, h=cage_thickness_mm, center=true);
    cylinder(r=cage_r_in,  h=cage_thickness_mm + 2*eps_mm, center=true);

    // ball pockets
    for (i = [0:num_balls-1]) {
      rotate([0,0, i*360/num_balls])
        translate([ball_path_r, 0, 0])
          cylinder(r=ball_r + 0.25, h=cage_thickness_mm + 2*eps_mm, center=true);
    }
  }
}

// Hidden structural bridges to guarantee a single connected solid:
// 1) Inner race <-> cage
// 2) Cage <-> outer race
// 3) Balls <-> cage (and thus to races)
// 4) Inner race <-> outer race (direct tie so races are not separated by ball path)
module structural_bridges() {
  // Cage radii (same as cage())
  cage_r_mid = ball_path_r;
  cage_r_in  = cage_r_mid - (ball_r + cage_radial_mm);
  cage_r_out = cage_r_mid + (ball_r + cage_radial_mm);

  // Keep bridges inside bearing width (centered)
  z0 = 0;

  // Helper: ensure bridge lengths are never negative (in case of parameter tweaks)
  function pos(x) = (x < 0) ? 0 : x;

  // (A) Inner race <-> cage: tabs overlap inner race OD and cage ID by overlap_mm
  // Recalculated translate radius so the cube spans [inner_race_or-overlap, cage_r_in+overlap]
  for (a = [0, 120, 240]) {
    radial_len = pos((cage_r_in - inner_race_or) + 2*overlap_mm);
    radial_ctr = (inner_race_or - overlap_mm) + radial_len/2;
    rotate([0,0,a])
      translate([radial_ctr, 0, z0])
        cube([radial_len, bridge_w_mm, bridge_z_mm], center=true);
  }

  // (B) Cage <-> outer race: tabs overlap cage OD and outer race ID by overlap_mm
  // Spans [cage_r_out-overlap, outer_race_ir+overlap]
  for (a = [60, 180, 300]) {
    radial_len = pos((outer_race_ir - cage_r_out) + 2*overlap_mm);
    radial_ctr = (cage_r_out - overlap_mm) + radial_len/2;
    rotate([0,0,a])
      translate([radial_ctr, 0, z0])
        cube([radial_len, bridge_w_mm, bridge_z_mm], center=true);
  }

  // (C) Balls <-> cage: "stitches" that intersect each ball AND the cage ring.
  // Make the stitch long enough to reach into the cage ring by overlap_mm.
  // Spans [ball_path_r-ball_r-overlap, cage_r_out+overlap] (guaranteed intersection with cage)
  for (i = [0:num_balls-1]) {
    ang = i*360/num_balls;

    radial_start = (ball_path_r - ball_r - overlap_mm);
    radial_end   = (cage_r_out + overlap_mm);
    radial_len   = pos(radial_end - radial_start);
    radial_ctr   = radial_start + radial_len/2;

    rotate([0,0,ang])
      translate([radial_ctr, 0, z0])
        cube([radial_len, bridge_w_mm, bridge_z_mm], center=true);
  }

  // (D) Inner race <-> outer race: direct ties so races are not separate bodies.
  // Spans [inner_race_or-overlap, outer_race_ir+overlap]
  for (a = [30, 150, 270]) {
    radial_len = pos((outer_race_ir - inner_race_or) + 2*overlap_mm);
    radial_ctr = (inner_race_or - overlap_mm) + radial_len/2;
    rotate([0,0,a])
      translate([radial_ctr, 0, z0])
        cube([radial_len, bridge_w_mm, bridge_z_mm], center=true);
  }
}

// Assembly: one connected solid
module ball_bearing() {
  union() {
    outer_race();
    inner_race();
    cage();
    balls();
    structural_bridges(); // ensures NO floating/disconnected parts
  }
}

ball_bearing();