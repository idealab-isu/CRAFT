$fn=64;

module smd_body(size=[3.0, 1.6, 1.05], corner_r=0.2) {
    x=size[0]; y=size[1]; z=size[2];
    r=min(corner_r, x/2, y/2);
    linear_extrude(height=z, center=true)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module smd_terminals(size=[3.0, 1.6, 1.05], term_len=0.35, term_thk=0.08, inset=0.02) {
    x=size[0]; y=size[1]; z=size[2];
    tlen=min(term_len, x/2);
    tthk=min(term_thk, z/2);
    for (sx=[-1,1]) {
        translate([sx*(x/2 - tlen/2 + inset), 0, -z/2 + tthk/2])
            cube([tlen, y*0.92, tthk], center=true);
    }
}

module smd(size=[3.0, 1.6, 1.05]) {
    union() {
        color([0.15,0.15,0.15]) smd_body(size=size, corner_r=0.2);
        color([0.75,0.75,0.75]) smd_terminals(size=size, term_len=0.35, term_thk=0.08, inset=0.02);
    }
}

smd([3.0, 1.6, 1.05]);