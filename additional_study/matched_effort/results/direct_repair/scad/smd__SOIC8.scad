$fn = 64;

size = [4.90, 3.90, 1.25];

module smd_body(sz=[4.90,3.90,1.25], corner_r=0.35) {
    r = min(corner_r, sz[0]/2, sz[1]/2);
    linear_extrude(height=sz[2])
        offset(r=r)
            square([sz[0]-2*r, sz[1]-2*r], center=true);
}

smd_body(size);