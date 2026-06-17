$fn = 64;

module smd_3_0_1_6_1_05(size=[3.0, 1.6, 1.05]) {
    // size = [length (X), width (Y), height (Z)] in mm
    l = size[0];
    w = size[1];
    h = size[2];

    // Simple SMD body with slight edge rounding via minkowski
    r = min(0.15, min(l, w, h) * 0.12);

    color([0.15, 0.15, 0.15])
    translate([0, 0, h/2])
    minkowski() {
        cube([l - 2*r, w - 2*r, h - 2*r], center=true);
        sphere(r=r);
    }

    // End terminations (pads) on both sides
    pad_len = l * 0.18;
    pad_thk = h * 0.35;
    pad_w   = w * 0.92;

    for (sx = [-1, 1]) {
        color([0.75, 0.75, 0.78])
        translate([sx*(l/2 - pad_len/2), 0, pad_thk/2])
            cube([pad_len, pad_w, pad_thk], center=true);
    }

    // Subtle top marking line
    color([0.9, 0.9, 0.9])
    translate([0, 0, h - 0.08])
        cube([l*0.55, w*0.08, 0.06], center=true);
}

smd_3_0_1_6_1_05([3.0, 1.6, 1.05]);