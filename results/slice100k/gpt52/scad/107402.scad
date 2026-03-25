$fn=96;

bbox_x = 3.5;
bbox_y = 1.7;
bbox_z = 9.1;

len = bbox_z;

outer_r = bbox_x/2;
wall = 0.35;
inner_r = outer_r - wall;

arc_deg = 140;

facets = 14;

module ring_segment_2d(ro, ri, ang){
    difference(){
        intersection(){
            difference(){
                circle(r=ro, $fn=facets);
                circle(r=ri, $fn=96);
            }
            rotate(-ang/2) circle(r=ro*3, $fn=96);
            rotate( ang/2) circle(r=ro*3, $fn=96);
        }
    }
}

module sleeve_segment(){
    linear_extrude(height=len, center=true, convexity=10)
        ring_segment_2d(outer_r, inner_r, arc_deg);
}

scale([1, bbox_y/(2*outer_r), 1])
    sleeve_segment();