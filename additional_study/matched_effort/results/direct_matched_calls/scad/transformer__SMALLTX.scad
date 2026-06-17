$fn=64;

module transformer(body=[38,32,33], corner_r=2.0) {
    // Simple mains transformer block with slightly rounded edges
    size = body;
    r = min(corner_r, min(size[0], min(size[1], size[2]))/2);

    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

transformer([38.0, 32.0, 33.0], corner_r=2.0);