smd = [6.5, 3.5, 1.6];

module smd_body(size=[6.5,3.5,1.6], corner_r=0.35){
    corner_r = min(corner_r, size[0]/2, size[1]/2, size[2]/2);
    minkowski(){
        cube([size[0]-2*corner_r, size[1]-2*corner_r, size[2]-2*corner_r], center=true);
        sphere(r=corner_r, $fn=48);
    }
}

smd_body(smd);