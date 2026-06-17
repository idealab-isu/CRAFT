// Aluminium rectangular box section: 12mm x 8mm x 1mm wall
// Length L along X, 12mm along Y, 8mm along Z.

L = 100;  //[50:200:1]
W = 12;   //[6:24:1]
H = 8;    //[4:16:1]
t = 1;    //[0.5:2:0.1]

// Small extra length so the inner cut cleanly opens both ends
eps = 0.5;

module box_section(L, W, H, t) {
    // Ensure valid wall thickness (avoid negative/zero inner dims)
    innerW = max(W - 2*t, 0.01);
    innerH = max(H - 2*t, 0.01);

    // Centered tube so end views clearly show the hollow opening
    difference() {
        cube([L, W, H], center=true);
        cube([L + 2*eps, innerW, innerH], center=true);
    }
}

union() {
    color([0.75, 0.75, 0.75])
        box_section(L, W, H, t);
}