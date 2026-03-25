// Rectangular hollow prism (box-section tube) with centered through-opening
// Bounding box: 0.8 x 0.3 x 0.3 mm (X x Y x Z), elongated along X

L = 0.8;     // length (X)
W = 0.3;     // width  (Y)
H = 0.3;     // height (Z)

wall_t = 0.03;   // uniform wall thickness
eps = 0.002;     // small overlap to ensure clean boolean through-cut

// Inner opening dimensions (must be positive and smaller than outer)
innerW = max(W - 2*wall_t, eps);
innerH = max(H - 2*wall_t, eps);

union() {
    difference() {
        // Outer tube (featureless exterior)
        cube([L, W, H], center=true);

        // Centered rectangular through-opening (slightly longer so ends are open)
        cube([L + 2*eps, innerW, innerH], center=true);
    }
}