// SMD package with terminals and slight top chamfer
// Overall target envelope: [11.40, 7.50, 2.00] mm
$fn = 48;

L = 11.40;
W = 7.50;
H = 2.00;

// Terminal geometry (kept within overall envelope)
term_len = 1.20;                 // length along X at each end
term_thk = 0.25;                 // thickness on bottom
term_w   = W * 0.78;             // terminal width along Y

// Small top chamfer (visual detail, still within envelope)
ch = 0.25;                       // chamfer amount
eps = 0.02;                      // overlap to ensure connectivity

module chamfered_body(l, w, h, c){
    // Create a subtle top chamfer by hulling a full-size base with a slightly smaller top
    hull() {
        translate([0,0,-h/2]) cube([l, w, eps], center=true);                 // bottom footprint
        translate([0,0, h/2 - eps/2]) cube([l-2*c, w-2*c, eps], center=true); // top footprint inset
    }
}

union() {
    // Main body (slightly shorter to make room for end terminals, still connected)
    chamfered_body(L - 2*term_len + 2*eps, W, H, ch);

    // Bottom terminals (connected with slight overlap into body)
    for (sx = [-1, 1]) {
        translate([sx*(L/2 - term_len/2), 0, -H/2 + term_thk/2])
            cube([term_len + eps, term_w, term_thk], center=true);
    }
}