$fn = 64;

// Miniature linear guide rail
rail_w = 15.0;   // width (X)
rail_h = 10.0;   // height (Z)
rail_l = 100.0;  // length (Y)

// Simple profile details (approximate)
top_flat_w = 9.0;
top_flat_h = 1.2;

side_chamfer = 1.2;   // chamfer size on top edges
bottom_relief_w = 7.0;
bottom_relief_h = 1.5;

hole_d = 4.2;         // mounting hole diameter
csk_d = 7.5;          // counterbore diameter
csk_h = 2.0;          // counterbore depth
end_margin = 10.0;
hole_pitch = 20.0;

module rail_body() {
    // Build a simple rail-like cross-section via polygon extrusion along Y
    // Cross-section in X-Z plane, centered at X=0, Z=0..rail_h
    w = rail_w;
    h = rail_h;
    tfw = top_flat_w;
    tfh = top_flat_h;
    ch = side_chamfer;
    brw = bottom_relief_w;
    brh = bottom_relief_h;

    // Ensure sane constraints
    tfw2 = min(tfw, w - 2*ch);
    brw2 = min(brw, w - 2*0.5);

    pts = [
        [-w/2, 0],
        [-w/2, h - tfh - ch],
        [-w/2 + ch, h - tfh],
        [-tfw2/2, h - tfh],
        [-tfw2/2, h],
        [ tfw2/2, h],
        [ tfw2/2, h - tfh],
        [ w/2 - ch, h - tfh],
        [ w/2, h - tfh - ch],
        [ w/2, 0],
        [ brw2/2, 0],
        [ brw2/2, brh],
        [-brw2/2, brh],
        [-brw2/2, 0]
    ];

    linear_extrude(height = rail_l, center = false, convexity = 10)
        polygon(points = pts);
}

module mounting_holes() {
    // Holes along Y, centered in X, drilled from top down
    // Place holes starting at end_margin, then every hole_pitch, ending before rail_l - end_margin
    for (y = [end_margin : hole_pitch : rail_l - end_margin + 0.001]) {
        // Through hole
        translate([0, y, rail_h/2])
            rotate([90, 0, 0])
                cylinder(d = hole_d, h = rail_w + 2, center = true);

        // Counterbore from top
        translate([0, y, rail_h - csk_h/2])
            rotate([90, 0, 0])
                cylinder(d = csk_d, h = rail_w + 2, center = true);
    }
}

difference() {
    // Orient: X=width, Y=length, Z=height
    rail_body();
    mounting_holes();
}