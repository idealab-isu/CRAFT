$fn = 96;

length = 200;
width  = 150;
thickness = 6;

module tooling_plate(l=200, w=150, t=6, corner_r=2) {
    color([0.75, 0.78, 0.82])
    linear_extrude(height=t)
        offset(r=corner_r)
            square([l - 2*corner_r, w - 2*corner_r], center=true);
}

tooling_plate(length, width, thickness, corner_r=2);