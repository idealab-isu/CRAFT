// SMD body target size: [3.0, 1.8, 0.9] (L, W, H)
// Single connected solid, no extra corner markers, no subtractive markings.

$fn = 48;

// Parameters
body_length = 3.0;  //[1.5:6.0:0.1]
body_width  = 1.8;  //[0.9:3.6:0.1]
body_height = 0.9;  //[0.45:1.8:0.05]

// Small edge softening (kept subtle so overall size remains correct)
edge_round = 0.08;  //[0:0.25:0.01]

// Helpers
module rounded_box(size=[1,1,1], r=0.1) {
    // Rounded edges via minkowski; overall size preserved by shrinking core.
    core = [
        max(size[0] - 2*r, 0.001),
        max(size[1] - 2*r, 0.001),
        max(size[2] - 2*r, 0.001)
    ];
    minkowski() {
        cube(core, center=true);
        sphere(r=r);
    }
}

// Final Output (one connected solid)
color([0.85, 0.85, 0.8])
rounded_box([body_length, body_width, body_height], edge_round);