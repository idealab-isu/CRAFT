$fn = 64;

size = [11.40, 7.50, 2.00];

module smd_body(sz=[11.40,7.50,2.00], corner_r=0.6) {
    r = min(corner_r, sz[0]/2, sz[1]/2, sz[2]/2);
    minkowski() {
        cube([sz[0]-2*r, sz[1]-2*r, sz[2]-2*r], center=true);
        sphere(r=r);
    }
}

smd_body(size, corner_r=0.6);