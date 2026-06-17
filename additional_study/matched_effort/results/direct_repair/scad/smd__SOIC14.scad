$fn = 64;

size = [8.70, 3.90, 1.25];

module smd_body(sz=[8.70, 3.90, 1.25], corner_r=0.35) {
    r = min(corner_r, sz[0]/2, sz[1]/2, sz[2]/2);
    minkowski() {
        cube([sz[0]-2*r, sz[1]-2*r, sz[2]-2*r], center=true);
        sphere(r=r);
    }
}

smd_body(size, corner_r=0.35);