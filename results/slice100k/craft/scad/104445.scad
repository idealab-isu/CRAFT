// Simple chamfered spacer block (mm)
L = 0.8;      // X
W = 0.8;      // Y
H = 1.2;      // Z
chamfer = 0.05; // planar bevel amount
$fn = 48;

module chamfered_block(L, W, H, c) {
    eps = 1e-6;
    c2 = min(c, L/2 - eps, W/2 - eps, H/2 - eps);

    // If chamfer is effectively zero, fall back to a plain cube
    if (c2 <= 0)
        cube([L, W, H], center=true);
    else
        minkowski() {
            cube([L - 2*c2, W - 2*c2, H - 2*c2], center=true);

            // Octahedron kernel -> flat chamfers (not rounded)
            polyhedron(
                points=[
                    [ c2, 0, 0], [-c2, 0, 0],
                    [ 0, c2, 0], [ 0,-c2, 0],
                    [ 0, 0, c2], [ 0, 0,-c2]
                ],
                faces=[
                    [0,2,4],[2,1,4],[1,3,4],[3,0,4],
                    [2,0,5],[1,2,5],[3,1,5],[0,3,5]
                ],
                convexity=10
            );
        }
}

chamfered_block(L, W, H, chamfer);