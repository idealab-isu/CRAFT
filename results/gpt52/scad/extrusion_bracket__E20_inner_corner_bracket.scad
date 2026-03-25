$fn=64;

bracket_size = [26, 25, 4.7];

module extrusion_bracket(size=[26,25,4.7], corner_r=2.0) {
    x = size[0];
    y = size[1];
    z = size[2];
    r = min(corner_r, min(x,y)/2);

    linear_extrude(height=z, center=true)
        offset(r=r)
            offset(delta=-r)
                square([x, y], center=true);
}

extrusion_bracket(bracket_size, corner_r=2.0);