$fn=96;

outer_x = 25.0;
outer_y = 21.7;
total_h = 4.0;

hole_d = 10.0;

step_h = 1.0;
mid_h = total_h - 2*step_h;

mid_scale = 0.88;

module hex2d(rx, ry){
    scale([rx, ry, 1])
        circle(r=1, $fn=6);
}

module hex_prism(rx, ry, h){
    linear_extrude(height=h, center=true)
        hex2d(rx, ry);
}

module stepped_hex_plate(){
    union(){
        hex_prism(outer_x/2, outer_y/2, total_h);
        hex_prism((outer_x/2)*mid_scale, (outer_y/2)*mid_scale, mid_h);
    }
}

difference(){
    stepped_hex_plate();
    cylinder(h=total_h+0.4, d=hole_d, center=true);
}