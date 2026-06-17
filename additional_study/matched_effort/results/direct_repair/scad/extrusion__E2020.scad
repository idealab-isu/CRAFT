$fn = 64;

length = 100;
size = 20;
corner_r = 1.0;

module extrusion_2020(len=100, s=20, r=1.0){
    linear_extrude(height=len, center=false, convexity=10)
        offset(r=r)
            offset(delta=-r)
                square([s, s], center=false);
}

extrusion_2020(length, size, corner_r);