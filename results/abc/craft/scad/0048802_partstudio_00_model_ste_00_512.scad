// Dimension-calibrated (target: 0.27 x 0.08 x 0.09 mm)
scale([0.889268, 0.880014, 0.810013])
{
// Symmetric stepped rectangular bar (single connected solid)
// Bounding box: 0.30 x 0.10 x 0.10 mm (X x Y x Z)

L = 0.30;
W_max = 0.10;
H_max = 0.10;

// Segment lengths along X (must sum to L)
end_L = 0.075;
mid_L = 0.15;
web_L = L - 2*end_L;          // 0.15

// Widths (Y) and heights (Z)
end_W = W_max;
end_H = H_max;

mid_W = 0.07;
mid_H = H_max;

web_W = 0.05;
web_H = 0.06;

overlap = 0.001;             // small overlap to guarantee connectivity

module part() {
    union() {
        // Central narrow web (full length between end blocks)
        cube([web_L, web_W, web_H], center=true);

        // Central thickened region (same height as ends, wider than web)
        cube([mid_L, mid_W, mid_H], center=true);

        // End blocks (largest pads), perfectly sharp corners
        translate([ web_L/2 + end_L/2 - overlap, 0, 0 ])
            cube([end_L, end_W, end_H], center=true);

        translate([ -web_L/2 - end_L/2 + overlap, 0, 0 ])
            cube([end_L, end_W, end_H], center=true);
    }
}

part();
}
