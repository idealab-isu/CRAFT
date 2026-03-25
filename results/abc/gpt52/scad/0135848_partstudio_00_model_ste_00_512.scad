$fn=64;

plate_thickness = 6;

module chamfered_plate(poly_pts, t=plate_thickness, chamfer=1.2){
    linear_extrude(height=t, center=true, convexity=10)
        offset(delta=-chamfer)
            offset(delta=chamfer)
                polygon(points=poly_pts);
}

module hex_hole(flat_to_flat=10, t=plate_thickness, extra=0.5){
    r = flat_to_flat / sqrt(3);
    translate([0,0,0])
        cylinder(h=t+2*extra, r=r, center=true, $fn=6);
}

module bracket_body(){
    pts = [
        [-34, -10],
        [-30, -16],
        [-18, -18],
        [-10, -14],
        [-6,  -9],
        [-4,  -4],
        [-6,   2],
        [-10,  7],
        [-18, 10],
        [-30,  8],
        [-34,  2],
        [-34, -10],

        [-6,  -9],
        [ 6, -18],
        [22, -22],
        [36, -16],
        [44,  -6],
        [46,   6],
        [40,  18],
        [26,  24],
        [10,  22],
        [ 0,  14],
        [-6,   2]
    ];

    difference(){
        chamfered_plate(pts, t=plate_thickness, chamfer=1.4);
        translate([-24, 0, 0]) hex_hole(flat_to_flat=12, t=plate_thickness, extra=1);
    }
}

bracket_body();