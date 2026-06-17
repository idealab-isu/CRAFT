// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

// Robustness
eps = 0.2;

// Main Body Module (single connected solid)
module main_body() {
    L = max(eps, body_length);
    W = max(eps, body_width);
    H = max(eps, body_height);

    // Ensure non-degenerate geometry and stable render
    color([0.85, 0.85, 0.8])
        cube([L, W, H], center=true);
}

// Final Model
main_body();