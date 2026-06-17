$fn = 64;

size = [3.0, 1.6, 1.05];

module smd_body(sz=[3.0,1.6,1.05], corner=0.15){
    corner_r = min(corner, sz[0]/2, sz[1]/2, sz[2]/2);
    minkowski(){
        cube([sz[0]-2*corner_r, sz[1]-2*corner_r, sz[2]-2*corner_r], center=true);
        sphere(r=corner_r);
    }
}

module smd_terminals(sz=[3.0,1.6,1.05], term_len=0.35, inset=0.02, term_thick=0.12){
    x = sz[0];
    y = sz[1];
    z = sz[2];

    tlen = min(term_len, x/2);
    tth = min(term_thick, z*0.6);

    for (sx = [-1, 1]){
        translate([sx*(x/2 - tlen/2 + inset), 0, -z/2 + tth/2])
            cube([tlen, y*0.92, tth], center=true);
    }
}

module smd_mark(sz=[3.0,1.6,1.05]){
    x = sz[0]; y = sz[1]; z = sz[2];
    translate([0, 0, z/2 - 0.02])
        linear_extrude(height=0.04)
            scale([1,1])
                square([x*0.35, y*0.18], center=true);
}

module smd(sz=[3.0,1.6,1.05]){
    // Body
    color([0.12,0.12,0.12])
        smd_body(sz, corner=0.18);

    // Terminals
    color([0.75,0.75,0.78])
        smd_terminals(sz, term_len=0.38, inset=0.01, term_thick=0.14);

    // Top mark
    color([0.85,0.85,0.85])
        smd_mark(sz);
}

smd(size);