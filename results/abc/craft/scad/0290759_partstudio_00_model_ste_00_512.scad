// Rounded-rectangle (square-like) solid block with uniform chamfer on all edges
// Bounding box: 0.1 x 0.1 x 0.1 mm

$fn = 48;

// Parameters (mm)
bbox_x = 0.1;
bbox_y = 0.1;
bbox_z = 0.1;

chamfer = 0.01;          // bevel distance along each face
corner_r = 0.012;        // XY corner rounding radius (rounded-rectangle outline)
eps = 0.0005;

// Clamp helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep parameters valid
ch = clamp(chamfer, eps, min(bbox_x, bbox_y, bbox_z)/2 - eps);
cr = clamp(corner_r, eps, min(bbox_x, bbox_y)/2 - ch - eps);

// 2D rounded rectangle (centered)
module rrect2d(w, h, r) {
    r2 = clamp(r, 0, min(w, h)/2 - eps);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)])
                circle(r=r2);
    }
}

// Main solid: rounded-rectangle prism, then chamfer all edges via Minkowski with octahedron
module chamfered_tile() {
    // Base prism with flat central faces (before chamfer)
    base_w = bbox_x - 2*ch;
    base_h = bbox_y - 2*ch;
    base_z = bbox_z - 2*ch;

    // Octahedron of "radius" ch creates planar 45° chamfers on all edges/corners
    module octa(r) {
        polyhedron(
            points=[
                [ r, 0, 0], [-r, 0, 0],
                [ 0, r, 0], [ 0,-r, 0],
                [ 0, 0, r], [ 0, 0,-r]
            ],
            faces=[
                [0,2,4],[2,1,4],[1,3,4],[3,0,4],
                [2,0,5],[1,2,5],[3,1,5],[0,3,5]
            ]
        );
    }

    minkowski() {
        // Rounded-rectangle outline in XY, uniform thickness in Z
        linear_extrude(height=base_z, center=true, convexity=10)
            rrect2d(base_w, base_h, cr);
        octa(ch);
    }
}

// Final output: one connected solid
chamfered_tile();