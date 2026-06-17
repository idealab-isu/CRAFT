$fn=64;

module frustum_poly(top_r=19.7, bot_r=16.8, h=36.4, n=8){
    linear_extrude(height=h, scale=bot_r/top_r, center=true, convexity=10)
        polygon(points=[for(i=[0:n-1]) [top_r*cos(360*i/n), top_r*sin(360*i/n)]]);
}

module truncated_prism_faceted(){
    // Scale to exact bounding box: 39.4 x 37.7 x 36.4
    // Base shape is symmetric; apply non-uniform XY scaling to match X/Y bounds.
    scale([1, 37.7/39.4, 1])
        frustum_poly(top_r=19.7, bot_r=16.8, h=36.4, n=8);
}

truncated_prism_faceted();