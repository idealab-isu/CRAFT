$fn=96;

bbox_x = 46.2;
bbox_y = 40.0;
th = 7.0;

hole_d = 10.0;
hole_offset = 6.0;

groove_depth = 1.2;
groove_width = 6.0;
land_width = 2.0;

module hex_prism_flat_to_flat(f2f, h){
    r = f2f / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module v_groove_cut(face_sign=1){
    // face_sign: +1 for +Y face, -1 for -Y face
    y_face = face_sign * (bbox_y/2);
    y_center = y_face - face_sign * (groove_depth/2);
    translate([0, y_center, 0])
        rotate([90,0,0])
            linear_extrude(height=groove_depth, center=true, convexity=10)
                polygon(points=[
                    [-bbox_x, -th],
                    [-land_width/2, 0],
                    [-land_width/2, groove_width],
                    [ land_width/2, groove_width],
                    [ land_width/2, 0],
                    [ bbox_x, -th]
                ]);
}

difference(){
    union(){
        hex_prism_flat_to_flat(bbox_y, th);
    }
    translate([0, hole_offset, 0])
        cylinder(h=th+2, d=hole_d, center=true, $fn=96);

    v_groove_cut(+1);
    v_groove_cut(-1);
}