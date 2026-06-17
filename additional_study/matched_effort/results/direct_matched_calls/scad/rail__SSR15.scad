$fn = 64;

// Miniature linear guide rail (approximate profile)
// Overall: 15.0mm wide, 12.5mm tall, 100mm long

w = 15.0;
h = 12.5;
L = 100.0;

// Profile features (tuned to look like a miniature rail)
top_flat_w = 7.0;
side_step_w = 2.0;
side_step_h = 3.0;
top_chamfer = 1.0;
bottom_chamfer = 0.8;

// Mounting holes
hole_d = 3.2;
csk_d  = 6.0;
csk_h  = 1.8;
hole_pitch = 25.0;
hole_edge_margin = 12.5; // from each end to first/last hole

module rail_profile_2d() {
    // Construct a symmetric rail-like cross-section using a polygon.
    // Coordinates in X (width) and Y (height), centered on X=0, base at Y=0.
    // Ensures overall width w and height h.
    polygon(points=[
        // left bottom to right bottom with small chamfers
        [-w/2 + bottom_chamfer, 0],
        [ w/2 - bottom_chamfer, 0],
        [ w/2, bottom_chamfer],

        // right side up to side step
        [ w/2, side_step_h],
        [ w/2 - side_step_w, side_step_h],

        // up to near top with chamfer into top flat
        [ w/2 - side_step_w, h - top_chamfer],
        [ top_flat_w/2 + top_chamfer, h - top_chamfer],
        [ top_flat_w/2, h],

        // across top flat
        [-top_flat_w/2, h],
        [-top_flat_w/2 - top_chamfer, h - top_chamfer],

        // down left side symmetric
        [-w/2 + side_step_w, h - top_chamfer],
        [-w/2 + side_step_w, side_step_h],
        [-w/2, side_step_h],
        [-w/2, bottom_chamfer]
    ]);
}

module rail_body() {
    linear_extrude(height=L, center=false, convexity=10)
        rail_profile_2d();
}

module mounting_holes() {
    // Through holes along centerline, with shallow counterbore/countersink-like recess on top
    for (z = [hole_edge_margin : hole_pitch : L - hole_edge_margin + 0.001]) {
        // through hole
        translate([0, h/2, z])
            rotate([90,0,0])
                cylinder(d=hole_d, h=h+2, center=true);

        // top recess (counterbore-ish)
        translate([0, h - csk_h/2, z])
            rotate([90,0,0])
                cylinder(d=csk_d, h=csk_h+0.2, center=true);
    }
}

difference() {
    rail_body();
    mounting_holes();
}