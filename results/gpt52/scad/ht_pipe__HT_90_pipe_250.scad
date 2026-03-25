$fn=96;

pipe_od = 250;
pipe_id = 230;
wall = (pipe_od - pipe_id)/2;

bend_angle = 90;
centerline_radius = 250;
straight_len = 250;

module pipe_segment(len, od, id){
    difference(){
        cylinder(h=len, d=od, center=false);
        translate([0,0,-0.5]) cylinder(h=len+1, d=id, center=false);
    }
}

module elbow_90(od, id, r_cl){
    rotate_extrude(angle=90, convexity=10)
        translate([r_cl,0,0])
            difference(){
                circle(d=od);
                circle(d=id);
            }
}

module ht_90_pipe_250mm(){
    union(){
        translate([0,0,0]) pipe_segment(straight_len, pipe_od, pipe_id);
        translate([0,0,straight_len]) elbow_90(pipe_od, pipe_id, centerline_radius);
        translate([centerline_radius,0,straight_len]) rotate([0,90,0]) pipe_segment(straight_len, pipe_od, pipe_id);
    }
}

translate([-centerline_radius/2,0,-straight_len/2]) ht_90_pipe_250mm();