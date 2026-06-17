// A axial: [3.4, 1.75, 0.3]

// Parameters
L = 3.4;   //[1.7:6.8:0.1]
W = 1.75;  //[0.875:3.5:0.05]
H = 0.3;   //[0.15:0.6:0.01]

$fn = 64;

// Single connected solid: rounded rectangular plate (no floating parts)
module axial_plate(len=L, wid=W, ht=H) {
    r = min(len, wid) * 0.18; // corner radius derived from dimensions
    r = max(r, 0.01);

    linear_extrude(height=ht, center=true)
        offset(r=r)
            square([len - 2*r, wid - 2*r], center=true);
}

axial_plate();