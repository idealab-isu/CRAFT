$fn=96;

L = 54.5;
W = 22.2;
H = 29.5;

center_len = 14.0;
end_len = (L - center_len)/2;

arm_w_end = W;
arm_w_center = 10.0;

arm_h_end = H;
arm_h_center = 16.0;

tri_aperture_end = 14.0;   // side length of triangular opening at each end face
tri_aperture_center = 4.0; // side length near center
tri_depth = end_len + 0.2; // slightly beyond to ensure clean cut

module tri_prism_x(len, side){
    htri = side*sqrt(3)/2;
    rotate([0,90,0])
        linear_extrude(height=len, center=true, convexity=10)
            polygon(points=[
                [-side/2, -htri/3],
                [ side/2, -htri/3],
                [ 0,      2*htri/3]
            ]);
}

module half_body(sign=1){
    // sign=1 for +X half, sign=-1 for -X half
    translate([sign*(center_len/2),0,0])
        linear_extrude(height=end_len, center=false, convexity=10, scale=[arm_w_end/arm_w_center, arm_h_end/arm_h_center])
            square([arm_w_center, arm_h_center], center=true);
}

module body(){
    union(){
        // central block
        linear_extrude(height=center_len, center=true, convexity=10)
            square([arm_w_center, arm_h_center], center=true);

        // flared arms
        half_body(1);
        mirror([1,0,0]) half_body(1);
    }
}

module triangular_voids(){
    // +X end void tapering toward center
    translate([L/2 - tri_depth/2, 0, 0])
        linear_extrude(height=tri_depth, center=true, convexity=10, scale=tri_aperture_center/tri_aperture_end)
            polygon(points=[
                [-tri_aperture_end/2, -(tri_aperture_end*sqrt(3)/2)/3],
                [ tri_aperture_end/2, -(tri_aperture_end*sqrt(3)/2)/3],
                [ 0,                   2*(tri_aperture_end*sqrt(3)/2)/3]
            ]);

    // -X end void tapering toward center
    mirror([1,0,0])
        translate([L/2 - tri_depth/2, 0, 0])
            linear_extrude(height=tri_depth, center=true, convexity=10, scale=tri_aperture_center/tri_aperture_end)
                polygon(points=[
                    [-tri_aperture_end/2, -(tri_aperture_end*sqrt(3)/2)/3],
                    [ tri_aperture_end/2, -(tri_aperture_end*sqrt(3)/2)/3],
                    [ 0,                   2*(tri_aperture_end*sqrt(3)/2)/3]
                ]);
}

module edge_chamfers(){
    // Create large angled faces by subtracting four long wedges around the body
    cham = 6.0;
    for (sy=[-1,1], sz=[-1,1]){
        translate([0, sy*(W/2 + cham/2), sz*(H/2 + cham/2)])
            rotate([0,0,45])
                cube([L+2, cham, cham], center=true);
    }
}

difference(){
    body();
    triangular_voids();
    edge_chamfers();
}