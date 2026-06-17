// Thin square frame plate
plate_L = 95.0; // mm
plate_W = 95.0; // mm
plate_T = 9.0;  // mm (depth/thickness)

border  = 12.0; // mm (uniform frame border)

module square_frame(L, W, T, b) {
    // Ensure a valid inner opening while keeping a single connected solid
    inner_L = max(L - 2*b, 0.1);
    inner_W = max(W - 2*b, 0.1);

    // Small epsilon to guarantee a clean through-cut without coplanar faces
    eps = 0.2;

    difference() {
        cube([L, W, T], center=true);
        cube([inner_L, inner_W, T + eps], center=true);
    }
}

square_frame(plate_L, plate_W, plate_T, border);