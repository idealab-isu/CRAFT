// Parameters
sheet_length = 200; //[100:400:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 12; //[6:24:1]
hole_diameter = 6;  //[3:12:0.5]
hole_edge_offset = 20; //[10:40:1]
chamfer_size = 1;   //[0.5:3:0.25]

// Quality
$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep parameters valid
cr = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2);
cs = clamp(chamfer_size, 0, min(sheet_thickness/2, min(sheet_length, sheet_width)/4));
he = clamp(hole_edge_offset, hole_diameter/2 + 0.5, min(sheet_length, sheet_width)/2 - hole_diameter/2 - 0.5);

// 2D profile: rectangle with clipped (chamfered) corners
module sheet_profile_2d(L, W, c) {
    polygon(points=[
        [ L/2 - c,  W/2],
        [-L/2 + c,  W/2],
        [-L/2,      W/2 - c],
        [-L/2,     -W/2 + c],
        [-L/2 + c, -W/2],
        [ L/2 - c, -W/2],
        [ L/2,     -W/2 + c],
        [ L/2,      W/2 - c]
    ]);
}

// 3D sheet with clipped corners
module sheet_solid() {
    linear_extrude(height=sheet_thickness, center=true, convexity=10)
        sheet_profile_2d(sheet_length, sheet_width, cr);
}

// Through holes
module mounting_holes() {
    hole_h = sheet_thickness + 0.2; // slight overshoot to guarantee cut-through
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(sheet_length/2 - he), sy*(sheet_width/2 - he), 0])
            cylinder(h=hole_h, r=hole_diameter/2, center=true);
}

// Chamfer top and bottom edges using Minkowski with a small 3D "diamond"
module chamfered_sheet() {
    // Shrink XY by cs and Z by cs so Minkowski restores to target size
    L2 = sheet_length - 2*cs;
    W2 = sheet_width  - 2*cs;
    T2 = sheet_thickness - 2*cs;

    if (cs <= 0) {
        sheet_solid();
    } else if (L2 <= 0 || W2 <= 0 || T2 <= 0) {
        // Fallback: no chamfer if parameters would invert geometry
        sheet_solid();
    } else {
        minkowski() {
            linear_extrude(height=T2, center=true, convexity=10)
                sheet_profile_2d(L2, W2, max(0, cr - cs));
            // L1 ball (octahedron) gives a clean 45° chamfer
            polyhedron(
                points=[
                    [ cs, 0, 0], [-cs, 0, 0],
                    [ 0, cs, 0], [ 0,-cs, 0],
                    [ 0, 0, cs], [ 0, 0,-cs]
                ],
                faces=[
                    [0,2,4],[2,1,4],[1,3,4],[3,0,4],
                    [2,0,5],[1,2,5],[3,1,5],[0,3,5]
                ]
            );
        }
    }
}

// Final Model (one connected solid with holes)
difference() {
    chamfered_sheet();
    mounting_holes();
}