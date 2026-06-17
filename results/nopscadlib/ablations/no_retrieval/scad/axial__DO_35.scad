$fn = 64;

// Target overall dimensions (A axial): [3.4, 1.75, 0.3]
length = 3.4;
width  = 1.75;
height = 0.3;

// Small edge rounding to make it look like a real axial body while
// keeping the exact overall bounding box dimensions.
edge_r = min(0.08, height/2 - 0.001, width/2 - 0.001, length/2 - 0.001);

module rounded_box_exact(L, W, H, r) {
    // Minkowski expands by r, so shrink core by 2r to keep exact outer size.
    minkowski() {
        cube([L - 2*r, W - 2*r, H - 2*r], center=true);
        sphere(r=r);
    }
}

module axial_body() {
    color([0.85, 0.85, 0.8])
        rounded_box_exact(length, width, height, edge_r);
}

axial_body();