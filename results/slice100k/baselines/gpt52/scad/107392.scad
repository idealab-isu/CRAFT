$fn=96;

module capsule_prism(size=[2.6,1.1,8.0], r=0.55){
    x=size[0]; y=size[1]; z=size[2];
    rr = min(r, x/2, y/2);
    linear_extrude(height=z, center=true, convexity=10)
        offset(r=rr)
            square([x-2*rr, y-2*rr], center=true);
}

capsule_prism([2.6,1.1,8.0], 0.55);