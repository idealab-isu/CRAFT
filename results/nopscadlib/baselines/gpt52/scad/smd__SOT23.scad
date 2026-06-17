$fn=64;

smd_size = [3, 1.4, 1.0];

module smd_body(size=[3,1.4,1.0]) {
    translate([0,0,size[2]/2])
        cube(size, center=true);
}

module smd_terminal(size=[3,1.4,1.0], end_len=0.35, inset=0.02) {
    term = [end_len, size[1]-2*inset, size[2]*0.55];
    translate([0,0,term[2]/2])
        cube(term, center=true);
}

module smd(size=[3,1.4,1.0]) {
    union() {
        smd_body(size);
        translate([ size[0]/2 - 0.35/2, 0, 0]) smd_terminal(size);
        translate([-size[0]/2 + 0.35/2, 0, 0]) smd_terminal(size);
    }
}

smd(smd_size);