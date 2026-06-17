$fn = 64;

module mains_transformer(size=[120,88,120], corner_r=4) {
    x = size[0];
    y = size[1];
    z = size[2];

    color([0.15,0.15,0.15])
    translate([-x/2, -y/2, 0])
    linear_extrude(height=z)
        offset(r=corner_r)
            square([x-2*corner_r, y-2*corner_r], center=false);
}

mains_transformer([120.0, 88.0, 120.0], corner_r=4);