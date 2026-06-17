$fn = 64;

// Miniature linear guide rail parameters (mm)
rail_w = 15.0;
rail_h = 10.0;
rail_l = 100.0;

// Simple profile details
top_flat_w = 9.0;          // flat on top
side_step_h = 2.0;         // small step height near top
side_step_inset = 1.5;     // inset for the step
bottom_chamfer = 1.0;      // bottom edge chamfer
top_edge_chamfer = 0.6;    // top edge chamfer

// Mounting holes (typical-ish)
hole_d = 3.4;              // clearance for M3
csk_d = 6.2;               // counterbore diameter
csk_depth = 2.2;           // counterbore depth
end_margin = 10.0;
hole_pitch = 20.0;

module rail_profile_points(w, h) {
    // 2D profile in XY, extruded along Z
    // Symmetric about X=0, bottom at Y=0, top at Y=h
    // Includes bottom chamfers, side steps, and top chamfers.
    w2 = w/2;

    // Key Y levels
    y0 = 0;
    y1 = bottom_chamfer;
    y2 = h - side_step_h;
    y3 = h - top_edge_chamfer;
    y4 = h;

    // Key X extents
    x0 = w2;
    x1 = w2 - bottom_chamfer;
    x2 = w2 - side_step_inset;
    x3 = top_flat_w/2;
    x4 = x3 + top_edge_chamfer;

    polygon(points=[
        // Start bottom right, go CCW
        [ x1, y0],
        [ x0, y1],
        [ x0, y2],
        [ x2, y2],
        [ x2, y3],
        [ x4, y4],
        [ x3, y4],
        [-x3, y4],
        [-x4, y4],
        [-x2, y3],
        [-x2, y2],
        [-x0, y2],
        [-x0, y1],
        [-x1, y0]
    ]);
}

module rail_body() {
    linear_extrude(height=rail_l, center=false, convexity=10)
        rail_profile_points(rail_w, rail_h);
}

module mounting_holes() {
    // Holes along length, centered in width, drilled from top down
    // Place holes at end_margin + n*hole_pitch within [0, rail_l]
    for (z = [end_margin : hole_pitch : rail_l - end_margin]) {
        // Through hole
        translate([0, rail_h/2, z])
            rotate([90,0,0])
                cylinder(d=hole_d, h=rail_h*2, center=true);

        // Counterbore from top
        translate([0, rail_h - csk_depth/2, z])
            rotate([90,0,0])
                cylinder(d=csk_d, h=csk_depth, center=true);
    }
}

difference() {
    rail_body();
    mounting_holes();
}