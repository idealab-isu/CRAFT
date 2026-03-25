$fn=64;

plate_x = 100;
plate_y = 100;
plate_t = 2;

corner_relief = 8;
relief_depth = 0.8;

module corner_cut(sx, sy) {
    translate([sx*(plate_x/2 - corner_relief), sy*(plate_y/2 - corner_relief), plate_t/2 - relief_depth])
        linear_extrude(height=relief_depth)
            polygon(points=[
                [0,0],
                [sx*corner_relief,0],
                [0,sy*corner_relief]
            ]);
}

difference() {
    translate([-plate_x/2, -plate_y/2, -plate_t/2])
        cube([plate_x, plate_y, plate_t], center=false);

    corner_cut( 1, 1);
    corner_cut(-1, 1);
    corner_cut(-1,-1);
    corner_cut( 1,-1);
}