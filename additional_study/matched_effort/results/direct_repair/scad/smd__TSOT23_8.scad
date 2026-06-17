$fn=64;

size = [3.0, 1.8, 0.9];

module smd_body(sz=[3,1.8,0.9], corner=0.2){
    corner_r = min(corner, sz[0]/2, sz[1]/2, sz[2]/2);
    minkowski(){
        cube([sz[0]-2*corner_r, sz[1]-2*corner_r, sz[2]-2*corner_r], center=true);
        sphere(r=corner_r);
    }
}

smd_body(size, corner=0.15);