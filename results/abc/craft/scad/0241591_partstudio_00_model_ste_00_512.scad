// Long rectangular hollow prism (box-section tube) with centered through-opening
// Bounding box: 0.8 x 0.3 x 0.3 mm (elongated along X)

L = 0.8;
W = 0.3;
H = 0.3;
t = 0.05;          // uniform wall thickness

// Use a tiny epsilon (in mm) to guarantee a clean through-cut without changing the bounding box
eps = 0.001;

// Inner void dimensions (centered)
inner_L = L + 2*eps;     // extend past both ends to ensure a true through-opening
inner_W = W - 2*t;
inner_H = H - 2*t;

// Ensure valid wall thickness / non-degenerate inner void
assert(inner_W > 0 && inner_H > 0, "Wall thickness too large for given W/H.");

difference() {
    // Outer prism (featureless exterior)
    cube([L, W, H], center=true);

    // Centered rectangular through-void (box-section tube)
    // Slightly longer than outer to ensure the cut fully opens both ends
    cube([inner_L, inner_W, inner_H], center=true);
}