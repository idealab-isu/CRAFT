// Simple chamfered spacer block
// Bounding box: 0.8 x 0.8 x 1.2 mm

body_x = 0.8;   //[0.4:1.6:0.01]
body_y = 0.8;   //[0.4:1.6:0.01]
body_z = 1.2;   //[0.6:2.4:0.01]
chamfer = 0.05; //[0.01:0.2:0.005]

$fn = 48;

module chamfered_cuboid(size=[1,1,1], c=0.05) {
    x = size[0]; y = size[1]; z = size[2];

    // Keep chamfer valid and non-degenerate
    c2 = max(0, min(c, x/2 - 1e-4, y/2 - 1e-4, z/2 - 1e-4));

    // 2D profile with 45° corner chamfers, extruded along Z (upright)
    linear_extrude(height=z, center=true, convexity=10)
        polygon(points=[
            [ x/2 - c2,  y/2],
            [-x/2 + c2,  y/2],
            [-x/2,       y/2 - c2],
            [-x/2,      -y/2 + c2],
            [-x/2 + c2, -y/2],
            [ x/2 - c2, -y/2],
            [ x/2,      -y/2 + c2],
            [ x/2,       y/2 - c2]
        ]);
}

chamfered_cuboid([body_x, body_y, body_z], chamfer);