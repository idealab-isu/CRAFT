$fn = 64;

length = 100;
size = 40;
corner_r = 2;

module extrusion_40x40(len=100, s=40, r=2) {
    linear_extrude(height=len, center=false, convexity=10)
        offset(r=r)
            offset(delta=-r)
                square([s, s], center=true);
}

extrusion_40x40(length, size, corner_r);