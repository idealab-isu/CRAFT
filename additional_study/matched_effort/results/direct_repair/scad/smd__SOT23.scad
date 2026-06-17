$fn = 64;

size = [3, 1.4, 1.0]; // [x, y, z] in mm

module smd_body(sz=[3,1.4,1.0]) {
    // Simple SMD package body with slight edge rounding via minkowski
    r = min(sz[0], sz[1], sz[2]) * 0.06;
    r = max(0.02, min(r, 0.15));
    minkowski() {
        cube([sz[0]-2*r, sz[1]-2*r, sz[2]-2*r], center=true);
        sphere(r=r);
    }
}

smd_body(size);