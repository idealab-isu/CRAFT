$fn = 64;

// Miniature linear guide rail (approximate profile)
// Overall: 15mm wide, 15mm tall, 100mm long

rail_w = 15.0;
rail_h = 15.0;
rail_l = 100.0;

// Profile details (tunable)
top_flat_w = 7.0;          // width of top flat
side_step_h = 3.0;         // height of lower side step
side_step_inset = 2.0;     // inset from each side at the step
top_chamfer = 1.0;         // chamfer size on top edges
bottom_chamfer = 0.8;      // chamfer size on bottom edges

// Mounting holes (typical rail style)
hole_d = 4.2;              // through hole diameter
csk_d = 7.8;               // counterbore diameter
csk_depth = 2.2;           // counterbore depth
end_margin = 12.0;         // distance from ends to first/last hole
hole_pitch = 25.0;         // spacing
hole_count = floor((rail_l - 2*end_margin)/hole_pitch) + 1;

module rail_profile_2d() {
    // Construct a stepped, chamfered profile within 15x15 envelope
    // Coordinates centered on X, base at Y=0
    w = rail_w;
    h = rail_h;

    // Key x positions
    x0 = -w/2;
    x1 = x0 + bottom_chamfer;
    x2 = -w/2 + side_step_inset;
    x3 = -top_flat_w/2 - top_chamfer;
    x4 = -top_flat_w/2;
    x5 = top_flat_w/2;
    x6 = top_flat_w/2 + top_chamfer;
    x7 = w/2 - side_step_inset;
    x8 = w/2 - bottom_chamfer;
    x9 = w/2;

    // Key y positions
    y0 = 0;
    y1 = bottom_chamfer;
    y2 = side_step_h;
    y3 = h - top_chamfer;
    y4 = h;

    polygon(points=[
        [x1, y0],
        [x8, y0],
        [x9, y1],
        [x9, y2],
        [x7, y2],
        [x7, y3],
        [x6, y3],
        [x5, y4],
        [x4, y4],
        [x3, y3],
        [x2, y3],
        [x2, y2],
        [x0, y2],
        [x0, y1]
    ]);
}

module rail_body() {
    linear_extrude(height=rail_l, center=false, convexity=10)
        rail_profile_2d();
}

module mounting_holes() {
    for (i = [0:hole_count-1]) {
        z = end_margin + i*hole_pitch;
        // Through hole
        translate([0, rail_h/2, z])
            rotate([90,0,0])
                cylinder(d=hole_d, h=rail_h+2, center=true);

        // Counterbore from top
        translate([0, rail_h - csk_depth/2, z])
            rotate([90,0,0])
                cylinder(d=csk_d, h=csk_depth+0.2, center=true);
    }
}

difference() {
    rail_body();
    mounting_holes();
}