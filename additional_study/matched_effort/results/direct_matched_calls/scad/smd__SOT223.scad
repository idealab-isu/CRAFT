size = [6.5, 3.5, 1.6];

module smd_body(sz=[6.5,3.5,1.6], corner_r=0.35) {
    r = min(corner_r, sz[0]/2, sz[1]/2, sz[2]/2);
    minkowski() {
        cube([sz[0]-2*r, sz[1]-2*r, sz[2]-2*r], center=true);
        sphere(r=r, $fn=48);
    }
}

smd_body(size);