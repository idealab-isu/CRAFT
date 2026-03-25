// Square frame-like panel, bounding box: 95 x 95 x 9 mm

outer_L = 95.0;      // mm
outer_W = 95.0;      // mm
thickness = 9.0;     // mm

border = 10.0;       // mm (uniform frame border)

inner_L = outer_L - 2*border;
inner_W = outer_W - 2*border;

difference() {
    cube([outer_L, outer_W, thickness], center=true);
    cube([inner_L, inner_W, thickness + 0.2], center=true); // slight overshoot ensures clean cut
}