$fn = 64;

module smd(size=[4.90, 3.90, 1.25], corner_r=0.35) {
    sx = size[0];
    sy = size[1];
    sz = size[2];
    r = min(corner_r, sx/2, sy/2);

    color([0.15, 0.15, 0.15])
    linear_extrude(height=sz)
        offset(r=r)
            square([sx-2*r, sy-2*r], center=true);
}

smd([4.90, 3.90, 1.25]);