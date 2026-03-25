// Dimension-calibrated (target: 0.03 x 0.17 x 0.17 mm)
scale([0.861386, 0.870005, 0.125001])
{
// Long prismatic stepped bar made from fused rectangular blocks (no holes/cutouts)
// Elongated along X, constant thickness Z, stepped width Y along length

L = 0.20;      // total length (X)
T = 0.20;      // thickness (Z)
W_max = 0.20;  // maximum width (Y)

// Segment lengths (sum to L)
seg_L1 = 0.04;
seg_L2 = 0.04;
seg_L3 = 0.04;
seg_L4 = 0.04;
seg_L5 = 0.04;

// Segment widths (Y) - stepped shoulders along length (fused end-to-end)
W1 = 0.20;
W2 = 0.14;
W3 = 0.20;
W4 = 0.14;
W5 = 0.20;

eps = 0.002; // overlap to guarantee connectivity and avoid coincident faces

module seg(len, wid, x_start_from_left) {
    // x_start_from_left measured from left end (0..L)
    translate([-L/2 + x_start_from_left + len/2, 0, 0])
        cube([len + eps, wid, T], center=true);
}

union() {
    seg(seg_L1, W1, 0);
    seg(seg_L2, W2, seg_L1);
    seg(seg_L3, W3, seg_L1 + seg_L2);
    seg(seg_L4, W4, seg_L1 + seg_L2 + seg_L3);
    seg(seg_L5, W5, seg_L1 + seg_L2 + seg_L3 + seg_L4);
}
}
