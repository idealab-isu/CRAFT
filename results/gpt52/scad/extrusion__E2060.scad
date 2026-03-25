$fn=64;

module tslot_2060_profile(len=100, w=60, h=20, corner_r=1.5) {
    linear_extrude(height=len, center=true, convexity=10)
        offset(r=corner_r)
            offset(delta=-corner_r)
                square([w, h], center=true);
}

tslot_2060_profile(len=100, w=60, h=20, corner_r=1.5);