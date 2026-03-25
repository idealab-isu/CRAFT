$fn=96;

plate_th = 8.0;
bbox_x = 46.2;
bbox_y = 40.0;

hole_d = 8.0;
hole_offset = [2.0, -1.0];

groove_w = 2.2;
groove_d = 0.9;
groove_len = 80;
groove_angle = 30;
groove_sep = 7.0;
groove_center = [0, 0];

module hex2d_flat_to_bbox(x, y){
    s = x/2;
    r = y/sqrt(3);
    scale([1, r/s]) circle(r=s, $fn=6);
}

module hex_prism(h){
    linear_extrude(height=h, center=true) hex2d_flat_to_bbox(bbox_x, bbox_y);
}

module perimeter_step_profile(){
    union(){
        hex_prism(plate_th);
        translate([0,0, plate_th/2 - 1.0/2]) linear_extrude(height=1.0, center=true)
            offset(delta=-1.2) hex2d_flat_to_bbox(bbox_x, bbox_y);
        translate([0,0,-plate_th/2 + 1.0/2]) linear_extrude(height=1.0, center=true)
            offset(delta=-0.8) hex2d_flat_to_bbox(bbox_x, bbox_y);
    }
}

module through_hole(){
    translate([hole_offset[0], hole_offset[1], 0])
        cylinder(d=hole_d, h=plate_th+2, center=true);
}

module groove_cut(pos=[0,0], ang=0){
    translate([pos[0], pos[1], plate_th/2 - groove_d/2 + 0.001])
        rotate([0,0,ang])
            cube([groove_len, groove_w, groove_d], center=true);
}

module grooves(){
    groove_cut([groove_center[0], groove_center[1] + groove_sep/2], groove_angle);
    groove_cut([groove_center[0], groove_center[1] - groove_sep/2], groove_angle);
}

difference(){
    perimeter_step_profile();
    through_hole();
    grooves();
}