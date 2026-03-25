// Dimension-calibrated (target: 0.13 x 0.20 x 0.03 mm)
scale([1.020006, 1.270020, 0.833367])
{
// L-shaped prismatic bracket with an open rectangular recess (step)
// Single connected solid, constant thickness (plate-like)

$fn = 64;

// Target overall footprint (approx): 0.1 x 0.2 mm
L = 0.2;          // overall length (X)
W = 0.1;          // overall width  (Y)
T = 0.03;         // thickness (Z) - cannot be 0 for a solid

// L geometry
pad_L    = 0.12;  // main block length
pad_W    = W;     // main block spans full width
flange_L = L - pad_L; // flange length
flange_W = 0.05;  // flange width (narrow arm)

// Recess (open step) carved from the flange side to create the L profile
recess_L = flange_L;          // recess runs along the flange length
recess_W = W - flange_W;      // removes the "missing" width to leave a narrow arm
overlap  = 0.002;

// Optional mounting holes (kept small)
hole_r = 0.004;
hole_edge_margin = 0.012;

module l_bracket_solid() {
  // Start from full bounding rectangle, then remove the step to form an L
  difference() {
    cube([L, W, T], center=true);

    // Step cutout: remove the upper portion of the flange region, leaving a narrow arm
    // Flange region in X: [pad_L/2 .. L/2]
    // Remove in Y: top band of width recess_W (i.e., everything except the narrow flange_W at bottom)
    translate([ (pad_L/2 + L/2)/2,  (W - recess_W)/2, 0 ])
      cube([recess_L + overlap, recess_W + overlap, T + 2*overlap], center=true);

    // Holes on the main pad only (avoid cutting into the flange)
    for (sy = [-1, 1]) {
      translate([ -L/2 + hole_edge_margin, sy*(W/2 - hole_edge_margin), 0 ])
        cylinder(r=hole_r, h=T + 2*overlap, center=true);
    }
  }
}

l_bracket_solid();
}
