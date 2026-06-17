// Symmetric double-ended wedge/clevis-like spacer with opposing flared arms
// and two opposing tapered triangular through-openings.
// Bounding box target: 54.5 x 22.2 x 29.5 mm (X x Y x Z)

$fn = 64;

// Overall bounds
L = 54.47;
W = 22.24;
H = 29.48;

// Central block (short)
block_L = 14.0;
block_W = W;
block_H = 16.0;

// Arms (each side)
arm_L_each = (L - block_L)/2;   // ensures exact overall length
arm_end_W  = W;
arm_end_H  = H;

// Waist (hourglass/X silhouette in side view)
waist_W = 12.5;
waist_H = 18.0;

// Triangular tunnel parameters (taper toward center)
tunnel_len_each = 22.0;         // from each end toward center
tri_entry_side  = 16.0;         // triangle size at the ends
tri_throat_side = 8.0;          // triangle size near the center

// Overlaps for robust booleans / solid connections
overlap = 1.2;

// Helpers
function tri_pts(side) =
    let(h = side*sqrt(3)/2)
    [ [0,  2*h/3],
      [-side/2, -h/3],
      [ side/2, -h/3] ];

module central_block() {
    cube([block_L, block_W, block_H], center=true);
}

// One arm as a polyhedron (local x from 0..arm_L_each), then mirrored for the other side.
// Cross-section in YZ is a rectangle that linearly scales from end (arm_end_*) to waist (*).
module arm_half_poly() {
    x0 = 0;
    x1 = arm_L_each;

    // End rectangle (at x0)
    y0 = arm_end_W/2;
    z0 = arm_end_H/2;

    // Waist rectangle (at x1)
    y1 = waist_W/2;
    z1 = waist_H/2;

    polyhedron(
        points=[
            // x0 end
            [x0, -y0, -z0], [x0,  y0, -z0], [x0,  y0,  z0], [x0, -y0,  z0],
            // x1 waist
            [x1, -y1, -z1], [x1,  y1, -z1], [x1,  y1,  z1], [x1, -y1,  z1]
        ],
        faces=[
            // end cap (x0)
            [0,1,2], [0,2,3],
            // waist cap (x1)
            [4,6,5], [4,7,6],
            // sides
            [0,4,5], [0,5,1],   // -Z face
            [1,5,6], [1,6,2],   // +Y face
            [2,6,7], [2,7,3],   // +Z face
            [3,7,4], [3,4,0]    // -Y face
        ],
        convexity=10
    );
}

module outer_body() {
    union() {
        central_block();

        // Place each arm so its WAIST face overlaps into the central block by `overlap`.
        // Left arm: local waist at x=arm_L_each should land at x = -block_L/2 + overlap
        left_arm_origin_x = (-block_L/2 + overlap) - arm_L_each;
        translate([left_arm_origin_x, 0, 0])
            arm_half_poly();

        // Right arm: mirror the left placement about X=0
        mirror([1,0,0])
            translate([left_arm_origin_x, 0, 0])
                arm_half_poly();
    }
}

// TRUE tapered triangular through-tunnel from one end toward the center.
// Implemented as a polyhedron "triangular pyramid frustum" aligned along X.
// This avoids orientation/axis mistakes and guarantees a clean through-cut.
module tapered_tri_tunnel_half(sign=1) {
    // sign = -1 for left end, +1 for right end
    // Start slightly outside the end face and extend inward.
    x0 = sign*(L/2 + overlap);
    x1 = sign*(L/2 - tunnel_len_each - overlap);

    // Triangle sizes
    s0 = tri_entry_side;
    s1 = tri_throat_side;

    // Triangle points in YZ plane (centered at Y=0,Z=0)
    // tri_pts() returns points around origin already.
    p0 = tri_pts(s0);
    p1 = tri_pts(s1);

    // Build polyhedron points: 0..2 at x0, 3..5 at x1
    polyhedron(
        points=[
            [x0, p0[0][0], p0[0][1]],
            [x0, p0[1][0], p0[1][1]],
            [x0, p0[2][0], p0[2][1]],

            [x1, p1[0][0], p1[0][1]],
            [x1, p1[1][0], p1[1][1]],
            [x1, p1[2][0], p1[2][1]]
        ],
        faces=[
            // caps (triangles)
            [0,1,2],
            [3,5,4],

            // side faces (each quad split into two triangles)
            [0,3,4], [0,4,1],
            [1,4,5], [1,5,2],
            [2,5,3], [2,3,0]
        ],
        convexity=10
    );
}

difference() {
    outer_body();

    // Two opposing tapered triangular through-openings (one from each end)
    tapered_tri_tunnel_half(-1);
    tapered_tri_tunnel_half( 1);
}