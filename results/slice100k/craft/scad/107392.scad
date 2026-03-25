// Bounding box (mm)
L = 8.0;
W = 2.6;
H = 1.1;

// Fillet radius (large long-edge fillets, rounded ends)
// Must be <= min(W,H)/2 to keep exact bounding box with Minkowski
r = 0.5;

fn = 64;

module rounded_capsule_prism(L, W, H, r) {
    r_eff = min(r, W/2, H/2);

    // Exact bounding box: Minkowski expands by r_eff in all directions,
    // so shrink the core by 2*r_eff on each axis.
    minkowski() {
        cube([L - 2*r_eff, W - 2*r_eff, H - 2*r_eff], center=true);
        sphere(r=r_eff, $fn=fn);
    }
}

rounded_capsule_prism(L, W, H, r);