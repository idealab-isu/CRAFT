// Radial parameters: [outer_d, inner_d, height, lip]
A = [17.4, 11.4, 9, 0.5];

outer_d = A[0];
inner_d = A[1];
h       = A[2];
lip     = A[3];

outer_r = outer_d/2;
inner_r = inner_d/2;

$fn = 180;

module radial_ring() {
    // Single connected solid: ring + small outer lip (integral, not floating)
    union() {
        // Main ring body
        difference() {
            cylinder(h=h, r=outer_r, center=true);
            cylinder(h=h + 0.02, r=inner_r, center=true);
        }

        // Outer lip (a thin radial step) centered so it overlaps the main ring
        // Ensures connectivity and matches lip thickness parameter.
        difference() {
            cylinder(h=lip, r=outer_r, center=true);
            cylinder(h=lip + 0.02, r=outer_r - lip, center=true);
        }
    }
}

radial_ring();