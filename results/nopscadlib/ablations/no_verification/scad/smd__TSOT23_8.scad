// SMD package (single connected solid) for A: [3.0, 1.8, 0.9]

// -------- Parameters --------
body_length = 3.0;   // X
body_width  = 1.8;   // Y
body_height = 0.9;   // Z

termination_length = 0.35;   // length of each end termination along X
termination_thickness = 0.08; // kept for compatibility (not used as separate shell to keep one solid)
termination_side_wrap = 0.12; // kept for compatibility (not used as separate shell to keep one solid)

top_chamfer = 0.12;
side_fillet_radius = 0.12;

$fn = 48;

// Small overlap to guarantee watertight unions/differences
eps = 0.02;

// -------- Helpers --------
function clamp(v, lo, hi) = min(max(v, lo), hi);

// Keep fillet/chamfer within sane bounds for this tiny part
fillet_r = clamp(side_fillet_radius, 0, min(body_width, body_height, body_length)/4);
chamfer  = clamp(top_chamfer, 0, min(body_width, body_height, body_length)/3);

// -------- Geometry --------
module body_core_with_top_chamfer() {
  // Start from a slightly oversized cube and cut 4 top-edge chamfers.
  // This avoids Minkowski "blank" issues from over-scaling and keeps dimensions stable.
  difference() {
    cube([body_length, body_width, body_height], center=true);

    // X+ top chamfer
    translate([ body_length/2 - chamfer/2 + eps, 0, body_height/2 - chamfer/2 + eps ])
      rotate([0, 45, 0])
        cube([chamfer, body_width + 2*eps, chamfer], center=true);

    // X- top chamfer
    translate([ -body_length/2 + chamfer/2 - eps, 0, body_height/2 - chamfer/2 + eps ])
      rotate([0, -45, 0])
        cube([chamfer, body_width + 2*eps, chamfer], center=true);

    // Y+ top chamfer
    translate([ 0, body_width/2 - chamfer/2 + eps, body_height/2 - chamfer/2 + eps ])
      rotate([45, 0, 0])
        cube([body_length + 2*eps, chamfer, chamfer], center=true);

    // Y- top chamfer
    translate([ 0, -body_width/2 + chamfer/2 - eps, body_height/2 - chamfer/2 + eps ])
      rotate([-45, 0, 0])
        cube([body_length + 2*eps, chamfer, chamfer], center=true);
  }
}

module rounded_body() {
  // Use Minkowski with a sphere to fillet edges.
  // To preserve the requested overall dimensions, shrink the core by 2*r in each axis first.
  core_x = max(body_length - 2*fillet_r, 0.01);
  core_y = max(body_width  - 2*fillet_r, 0.01);
  core_z = max(body_height - 2*fillet_r, 0.01);

  minkowski() {
    // Apply chamfer to the shrunken core so the final outer size remains correct.
    scale([core_x/body_length, core_y/body_width, core_z/body_height])
      body_core_with_top_chamfer();

    sphere(r=fillet_r);
  }
}

module terminations_solid() {
  // End terminations are modeled as solid blocks that overlap into the body,
  // ensuring ONE connected solid (no floating parts).
  term_x = termination_length;
  term_y = body_width;
  term_z = body_height;

  // Place each termination so its outer face is flush with the body end.
  // Overlap slightly into the body by eps to guarantee connectivity.
  translate([-(body_length/2 - term_x/2) + eps, 0, 0])
    cube([term_x + 2*eps, term_y, term_z], center=true);

  translate([ (body_length/2 - term_x/2) - eps, 0, 0])
    cube([term_x + 2*eps, term_y, term_z], center=true);
}

module smd_complete_model() {
  // Single connected solid: body + terminations unioned with overlap.
  union() {
    rounded_body();
    terminations_solid();
  }
}

// -------- Final Output --------
smd_complete_model();