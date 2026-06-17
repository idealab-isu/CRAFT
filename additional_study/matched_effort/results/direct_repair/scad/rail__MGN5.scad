$fn = 64;

// Miniature linear guide rail
rail_w = 5.0;     // width (X)
rail_h = 3.6;     // height (Z)
rail_l = 100.0;   // length (Y)

module rail_profile(w, h) {
    // Simple realistic-ish profile: rectangular body with small top chamfers
    cham = min(0.6, w*0.18, h*0.25);

    // 2D profile in X-Z plane, centered on X, bottom at Z=0
    polygon(points=[
        [-w/2, 0],
        [ w/2, 0],
        [ w/2, h-cham],
        [ w/2-cham, h],
        [-w/2+cham, h],
        [-w/2, h-cham]
    ]);
}

module linear_guide_rail(w, h, l) {
    // Extrude along Y
    rotate([90,0,0])
        linear_extrude(height=l, center=false, convexity=10)
            rail_profile(w, h);
}

linear_guide_rail(rail_w, rail_h, rail_l);