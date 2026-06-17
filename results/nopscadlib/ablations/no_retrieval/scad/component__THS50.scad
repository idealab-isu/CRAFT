// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 20; //[10:40:1]

// Robustness
eps = 0.01;
L = max(body_length, eps);
W = max(body_width,  eps);
H = max(body_height, eps);

// Small overlap to guarantee connectivity
overlap = 1;

// Connected component: main block + top boss + side lug (all dimension-driven)
module component() {
    boss_r = max(min(L, W) * 0.18, 2);
    boss_h = max(H * 0.35, 2);

    lug_w = max(L * 0.22, 2);
    lug_d = max(W * 0.45, 2);
    lug_h = max(H * 0.55, 2);

    union() {
        // Main body
        cube([L, W, H], center=true);

        // Top boss (connected to top face with overlap)
        translate([0, 0, H/2 + boss_h/2 - overlap])
            cylinder(r=boss_r, h=boss_h, center=true, $fn=64);

        // Side lug (connected to +X face with overlap)
        translate([L/2 + lug_w/2 - overlap, 0, 0])
            cube([lug_w, lug_d, lug_h], center=true);
    }
}

component();