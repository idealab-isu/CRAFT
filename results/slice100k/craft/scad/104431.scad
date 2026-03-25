// Chamfered spacer block with mid-length bulge (wider at center, narrower at ends)
// Bounding box: 0.8 x 0.8 x 2.0 mm

$fn = 64;

// Parameters (mm)
L       = 2.0;   // length (Z)
W_max   = 0.8;   // max width at mid (X)
D_max   = 0.8;   // max depth at mid (Y)
W_end   = 0.72;  // width at ends (Z = +/- L/2)
D_end   = 0.72;  // depth at ends (Z = +/- L/2)
chamfer = 0.08;  // vertical edge bevel amount (corner cut in plan)
overlap = 0.02;  // small thickness for hull slices (robust)

// Clamp chamfer so it can't invert geometry
ch = min(chamfer, min(W_end, D_end, W_max, D_max)/2 - 0.001);

// 2D chamfered rectangle (flat sides + beveled corners)
module chamfered_rect_2d(w, d, c) {
    polygon(points=[
        [ w/2 - c,  d/2],
        [-w/2 + c,  d/2],
        [-w/2,      d/2 - c],
        [-w/2,     -d/2 + c],
        [-w/2 + c, -d/2],
        [ w/2 - c, -d/2],
        [ w/2,     -d/2 + c],
        [ w/2,      d/2 - c]
    ]);
}

// Main solid: tapered ends + bulged mid, with vertical edge chamfers
module spacer_block() {
    // Use hull between multiple Z cross-sections to make the lengthwise taper
    // clearly visible in orthographic side views.
    hull() {
        // bottom end
        translate([0,0,-L/2])
            linear_extrude(height=overlap, center=true)
                chamfered_rect_2d(W_end, D_end, ch);

        // lower shoulder (helps show taper)
        translate([0,0,-L/4])
            linear_extrude(height=overlap, center=true)
                chamfered_rect_2d(
                    W_end + (W_max - W_end)*0.65,
                    D_end + (D_max - D_end)*0.65,
                    ch
                );

        // mid bulge
        translate([0,0,0])
            linear_extrude(height=overlap, center=true)
                chamfered_rect_2d(W_max, D_max, ch);

        // upper shoulder
        translate([0,0, L/4])
            linear_extrude(height=overlap, center=true)
                chamfered_rect_2d(
                    W_end + (W_max - W_end)*0.65,
                    D_end + (D_max - D_end)*0.65,
                    ch
                );

        // top end
        translate([0,0, L/2])
            linear_extrude(height=overlap, center=true)
                chamfered_rect_2d(W_end, D_end, ch);
    }
}

spacer_block();