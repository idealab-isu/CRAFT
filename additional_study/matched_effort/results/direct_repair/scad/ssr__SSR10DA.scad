$fn = 64;

module ssr_module(size=[58,45,33], corner_r=2.5) {
    x = size[0];
    y = size[1];
    z = size[2];

    // Rounded rectangular prism
    linear_extrude(height=z)
        offset(r=corner_r)
            square([x-2*corner_r, y-2*corner_r], center=true);
}

ssr_module([58.0, 45.0, 33.0], corner_r=2.5);