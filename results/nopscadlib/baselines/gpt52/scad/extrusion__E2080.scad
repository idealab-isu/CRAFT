$fn=64;

module tslot_2080_profile(len=100, w=80, h=20, corner_r=1.5) {
    linear_extrude(height=len, center=true, convexity=10)
        offset(r=corner_r)
            square([w-2*corner_r, h-2*corner_r], center=true);
}

tslot_2080_profile(len=100, w=80, h=20, corner_r=1.5);