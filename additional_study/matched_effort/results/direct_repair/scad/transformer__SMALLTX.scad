$fn = 64;

module mains_transformer(size=[38.0, 32.0, 33.0], corner_r=2.0) {
    x = size[0];
    y = size[1];
    z = size[2];
    r = min(corner_r, min(x,y)/2);

    // Rounded rectangular prism
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

mains_transformer();