// Symmetric double-ended wedge/clevis-like spacer with opposing flared arms
// and two opposing tapered triangular tunnels.
// Bounding box target: 54.5 x 22.2 x 29.5 mm (L x W x H)

$fn = 96;

// --- Target overall size ---
L = 54.5;
W = 22.2;
H = 29.5;

// --- Shape controls ---
center_L = 14.0;                 // short central block length
arm_L_each = (L - center_L)/2;   // computed to hit overall L

waist_W = 12.0;                  // narrow waist width (Y)
waist_H = 16.0;                  // narrow waist height (Z)

end_W = W;                       // end width (Y)
end_H = H;                       // end height (Z)

overlap = 0.8;                   // overlap to guarantee connectivity

// End chamfer depth along X (creates angled end faces)
end_chamfer = 3.0;

// Triangular tunnel parameters (tapering toward center)
tri_end_side = 14.0;             // triangle side at the end face
tri_center_side = 8.0;           // triangle side near the center (smaller)
tri_clear = 0.5;                 // clearance added to triangle size
tri_depth_each_end = arm_L_each; // tunnel depth from each end toward center

// Extra length for cutters to ensure clean subtraction
cut_extra = 1.0;

// ----------------- Helpers -----------------
function tri_h(side) = side * sqrt(3) / 2;

// Equilateral triangle centered at origin in YZ plane (2D polygon in YZ)
module tri2d(side) {
    s = side;
    h = tri_h(s);
    polygon(points=[
        [ 0,        2*h/3],
        [-s/2,     -h/3 ],
        [ s/2,     -h/3 ]
    ]);
}

// 2D trapezoid in XZ (for side-view hourglass), centered at origin.
// width at center = w0, width at ends = w1, total length = len
module trapezoid_xz(len, w0, w1) {
    polygon(points=[
        [-len/2, -w1/2],
        [ len/2, -w1/2],
        [ len/2,  w1/2],
        [-len/2,  w1/2]
    ]);
}

// Outer envelope: central + two arms, with true flare (hourglass/X in side views)
// Achieved by intersecting two orthogonal "hourglass prisms" (one controls Y vs X, one controls Z vs X)
module outer_envelope() {
    // Prism controlling Y flare along X (extruded in Z)
    module prismY() {
        linear_extrude(height=H + 2*cut_extra, center=true, convexity=10)
            polygon(points=[
                [-L/2, -end_W/2],
                [ L/2, -end_W/2],
                [ L/2,  end_W/2],
                [-L/2,  end_W/2]
            ]);
        // Replace above with true trapezoid in XY:
        // (OpenSCAD doesn't allow easy "variable width" rectangle without polygon)
    }

    // True trapezoid in XY (Y width varies with X)
    module prismY_true() {
        linear_extrude(height=H + 2*cut_extra, center=true, convexity=10)
            polygon(points=[
                [-L/2, -end_W/2],
                [-center_L/2, -waist_W/2],
                [ center_L/2, -waist_W/2],
                [ L/2, -end_W/2],
                [ L/2,  end_W/2],
                [ center_L/2,  waist_W/2],
                [-center_L/2,  waist_W/2],
                [-L/2,  end_W/2]
            ]);
    }

    // True trapezoid in XZ (Z height varies with X), extruded in Y
    module prismZ_true() {
        rotate([90,0,0])  // extrude along Y
            linear_extrude(height=W + 2*cut_extra, center=true, convexity=10)
                polygon(points=[
                    [-L/2, -end_H/2],
                    [-center_L/2, -waist_H/2],
                    [ center_L/2, -waist_H/2],
                    [ L/2, -end_H/2],
                    [ L/2,  end_H/2],
                    [ center_L/2,  waist_H/2],
                    [-center_L/2,  waist_H/2],
                    [-L/2,  end_H/2]
                ]);
    }

    // Intersect to get an "X/hourglass" silhouette in both side views
    intersection() {
        prismY_true();
        prismZ_true();
    }
}

// End chamfer cutters: subtract frustums to create angled end faces
module end_chamfer_cutter(side_sign=1) {
    x_end = side_sign * (L/2);
    x_c = x_end - side_sign*(end_chamfer/2);

    // Frustum along X: larger at outside, smaller inward
    // Use linear_extrude along X by rotating a 2D square in YZ.
    translate([x_c, 0, 0])
        rotate([0, 90*side_sign, 0])
            linear_extrude(
                height=end_chamfer + 2*cut_extra,
                center=true,
                convexity=10,
                scale=[(end_W - 2*end_chamfer)/end_W, (end_H - 2*end_chamfer)/end_H]
            )
                square([end_W + 2*cut_extra, end_H + 2*cut_extra], center=true);
}

// Tapered triangular tunnel from each end toward center (triangular through-opening)
module tri_tunnel(side_sign=1) {
    // Place the cutter so its outer face aligns with the end face at x = +/- L/2
    // With center=true extrusion, the extrude spans [x_mid - h/2, x_mid + h/2] in local X after rotation.
    // Choose x_mid so the outermost reaches the end face.
    h_ex = tri_depth_each_end + 2*cut_extra;
    x_mid = side_sign * (L/2 - h_ex/2 + cut_extra);

    translate([x_mid, 0, 0])
        rotate([0, 90*side_sign, 0])
            linear_extrude(
                height=h_ex,
                center=true,
                convexity=10,
                scale=( (tri_center_side + 2*tri_clear) / (tri_end_side + 2*tri_clear) )
            )
                tri2d(tri_end_side + 2*tri_clear);
}

// ----------------- Final model -----------------
difference() {
    // Base solid (single connected body)
    outer_envelope();

    // End chamfers
    end_chamfer_cutter(-1);
    end_chamfer_cutter(+1);

    // Two opposing tapered triangular tunnels (one from each end)
    tri_tunnel(-1);
    tri_tunnel(+1);
}