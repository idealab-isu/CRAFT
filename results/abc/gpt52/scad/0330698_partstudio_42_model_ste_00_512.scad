$fn=64;

plate_th = 2;

module diamond_hole(size=6, th=plate_th+2) {
    rotate([0,0,45]) cube([size, size, th], center=true);
}

module rounded_polygon(points, r=2) {
    union() {
        linear_extrude(height=plate_th, center=true)
            offset(r=r) offset(delta=-r)
                polygon(points=points);
    }
}

module mounting_plate() {
    pts = [
        [-50,-35],
        [-20,-35],
        [-20,-45],
        [ 10,-45],
        [ 10,-35],
        [ 50,-35],
        [ 50,  0],
        [ 35,  0],
        [ 35, 35],
        [  0, 35],
        [  0, 45],
        [-30, 45],
        [-30, 35],
        [-50, 35]
    ];

    difference() {
        rounded_polygon(pts, r=3);

        // Group A (left)
        translate([-28, -10, 0]) diamond_hole(size=6);
        translate([-28,  10, 0]) diamond_hole(size=6);
        translate([-10,   0, 0]) diamond_hole(size=6);

        // Group B (right)
        translate([ 10, -10, 0]) diamond_hole(size=6);
        translate([ 10,  10, 0]) diamond_hole(size=6);
        translate([ 28,   0, 0]) diamond_hole(size=6);
    }
}

mounting_plate();