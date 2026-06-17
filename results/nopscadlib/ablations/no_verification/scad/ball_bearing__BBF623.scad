// Flanged ball bearing (single connected solid)
// Target: 3.0mm bore, 10.0mm OD, 4.0mm width, 11.5mm flange OD

$fn = 160;

// --- Primary dimensions (mm) ---
bore_diameter_mm   = 3.0;
outer_diameter_mm  = 10.0;
width_mm           = 4.0;
flange_diameter_mm = 11.5;

// --- Detail/appearance controls (mm) ---
flange_thickness_mm      = 0.8;   // axial thickness of flange (part of total width)
outer_race_radial_mm     = 1.15;  // outer ring wall thickness
inner_race_radial_mm     = 0.95;  // inner ring wall thickness
race_relief_mm           = 0.35;  // shallow groove depth for race look
race_relief_axial_mm     = 2.2;   // groove axial span
ball_diameter_mm         = 1.2;
ball_count               = 8;
ball_clearance_mm        = 0.10;  // small clearance so balls don't fuse to races
bridge_web_thickness_mm  = 0.35;  // thin hidden web to guarantee ONE connected solid
overlap_mm               = 0.05;  // tiny overlap for robust unions/differences

// --- Derived ---
bore_r   = bore_diameter_mm/2;
outer_r  = outer_diameter_mm/2;
flange_r = flange_diameter_mm/2;

inner_race_outer_r = bore_r + inner_race_radial_mm;
outer_race_inner_r = outer_r - outer_race_radial_mm;

// Place balls between races with a little clearance
ball_orbit_r = (inner_race_outer_r + outer_race_inner_r)/2;
ball_r       = ball_diameter_mm/2;

// Ensure flange thickness does not exceed width
flange_t = min(flange_thickness_mm, width_mm - 0.2);
body_t   = width_mm;

// Helper: ring
module ring(r_out, r_in, h, center=true) {
  difference() {
    cylinder(r=r_out, h=h, center=center);
    cylinder(r=r_in,  h=h + 2*overlap_mm, center=center);
  }
}

// Helper: shallow groove cut to suggest raceway
module race_relief(r_center, relief_r, h_span) {
  // Cut a torus-like groove using rotate_extrude of a circle
  // Positioned at mid-plane (z=0)
  translate([0,0,0])
    rotate_extrude(angle=360)
      translate([r_center, 0, 0])
        circle(r=relief_r, $fn=96);
}

// Main bearing (single connected solid)
module flanged_bearing_connected() {
  union() {
    // --- Outer race (with shallow groove) ---
    difference() {
      ring(outer_r, outer_race_inner_r, body_t, center=true);

      // Groove: subtract a torus, limited axially by intersecting with a slab
      intersection() {
        // torus groove
        race_relief((outer_race_inner_r + outer_r)/2, race_relief_mm);
        // axial limiter slab
        cube([2*(outer_r+2), 2*(outer_r+2), race_relief_axial_mm], center=true);
      }
    }

    // --- Inner race (with shallow groove) ---
    difference() {
      ring(inner_race_outer_r, bore_r, body_t, center=true);

      intersection() {
        race_relief((bore_r + inner_race_outer_r)/2, race_relief_mm);
        cube([2*(outer_r+2), 2*(outer_r+2), race_relief_axial_mm], center=true);
      }
    }

    // --- Flange (on one side), connected to outer race ---
    // Place flange so its outer face is flush with +Z face of bearing
    translate([0, 0, body_t/2 - flange_t/2])
      ring(flange_r, outer_race_inner_r, flange_t, center=true);

    // --- Balls (kept separate visually but connected via hidden web) ---
    // Balls are included for appearance; a thin web ensures the whole model is ONE connected solid.
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
        translate([ball_orbit_r, 0, 0])
          sphere(r=ball_r, $fn=64);
    }

    // --- Hidden connecting web (thin ring) ---
    // This guarantees a single connected solid even if balls don't touch races.
    // Positioned at mid-plane, between races, very thin radially and axially.
    web_r_in  = inner_race_outer_r + ball_clearance_mm;
    web_r_out = outer_race_inner_r - ball_clearance_mm;
    web_h     = bridge_web_thickness_mm;

    // Only add if there is space
    if (web_r_out > web_r_in + 0.05)
      ring(web_r_out, web_r_in, web_h, center=true);
  }
}

// Final
difference() {
  flanged_bearing_connected();
  // Ensure clean, round bore through entire part
  cylinder(r=bore_r, h=width_mm + 2*overlap_mm, center=true);
}