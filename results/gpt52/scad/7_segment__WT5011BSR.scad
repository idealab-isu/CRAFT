$fn=64;

dims = [12.7, 19, 8.2];

module seven_segment_body(size=[12.7,19,8.2]) {
    translate([-size[0]/2, -size[1]/2, -size[2]/2])
        cube(size, center=false);
}

seven_segment_body(dims);