// Simple hollow cylindrical sleeve (tube/spacer)
// Bounding box: 6.35 x 6.35 x 25.65 mm

L  = 25.65;
OD = 6.35;
ID = 3.175;

// Smoothness (avoid faceted look)
$fn = 128;

module sleeve(L, OD, ID) {
    difference() {
        cylinder(h = L, d = OD, center = true);
        // Slightly longer bore to guarantee a clean through-cut
        cylinder(h = L + 0.2, d = ID, center = true);
    }
}

color([0.85, 0.85, 0.8])
sleeve(L, OD, ID);