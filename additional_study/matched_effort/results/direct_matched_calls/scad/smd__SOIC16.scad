$fn = 64;

size = [9.90, 3.90, 1.25];

module smd_body(sz=[9.90,3.90,1.25], r=0.35){
    r2 = min(r, sz[0]/2, sz[1]/2, sz[2]/2);
    minkowski(){
        cube([sz[0]-2*r2, sz[1]-2*r2, sz[2]-2*r2], center=true);
        sphere(r=r2);
    }
}

smd_body(size, r=0.35);