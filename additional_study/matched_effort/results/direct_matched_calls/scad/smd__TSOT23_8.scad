$fn = 64;

size = [3.0, 1.8, 0.9]; // [X, Y, Z] in mm

module smd_body(sz=[3,1.8,0.9]) {
    // Simple SMD package body with slight edge rounding
    r = min(sz[0], sz[1], sz[2]) * 0.08;
    r = max(r, 0.02);

    minkowski() {
        cube([sz[0]-2*r, sz[1]-2*r, sz[2]-2*r], center=true);
        sphere(r=r);
    }
}

smd_body(size);