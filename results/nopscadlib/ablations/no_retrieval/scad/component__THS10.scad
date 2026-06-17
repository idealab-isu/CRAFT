// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

$fn = 64;

// Main Body (single connected solid)
module component() {
    // Ensure non-degenerate dimensions so geometry always renders
    L = max(0.1, body_length);
    W = max(0.1, body_width);
    H = max(0.1, body_height);

    color([0.85, 0.85, 0.8])
        cube([L, W, H], center=true);
}

// Final Model
component();