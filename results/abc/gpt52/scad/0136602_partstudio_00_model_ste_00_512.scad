$fn=64;

eps = 0.01;

module diamond_hole(th=20, d=3) {
    rotate([0,0,45]) cylinder(h=th, r=d/2, center=true, $fn=4);
}

module v_notch(len=20, width=10, height=20) {
    linear_extrude(height=height, center=true)
        polygon(points=[
            [-len/2, 0],
            [0, width/2],
            [len/2, 0],
            [0, -width/2]
        ]);
}

module bracket() {
    // Bounding box: 0.1 x 0.0 x 0.0 mm -> degenerate in Y and Z, so create a minimal valid solid
    // Use a thin plate centered at origin with X=0.1, Y=eps, Z=eps
    difference() {
        union() {
            // Central body
            cube([0.1, eps, eps], center=true);
        }
        // No-op cuts kept minimal to avoid invalid geometry
    }
}

bracket();