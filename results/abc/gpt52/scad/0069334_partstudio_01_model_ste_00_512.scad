$fn=64;

outer_d = 0.1;
inner_d = 0.05;
h = 0.1;

facets = 14;
irreg_amp = 0.004;
seed = 7;

module faceted_outer_profile(od=outer_d, n=facets, amp=irreg_amp, s=seed){
    pts = [
        for (i = [0:n-1]) 
            let(a = 360*i/n)
            let(r = od/2 + amp*(sin((i+1)*37 + s*11) + 0.6*cos((i+1)*19 + s*7)))
            [r*cos(a), r*sin(a)]
    ];
    polygon(points=pts);
}

module ring(){
    difference(){
        linear_extrude(height=h, center=true, convexity=10)
            faceted_outer_profile();
        cylinder(d=inner_d, h=h+0.02, center=true, $fn=96);
    }
}

ring();