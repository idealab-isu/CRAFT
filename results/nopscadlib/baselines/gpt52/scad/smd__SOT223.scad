$fn=64;

module smd_body(size=[6.5,3.5,1.6], corner_r=0.4){
    x=size[0]; y=size[1]; z=size[2];
    r=min(corner_r, x/2, y/2, z/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1])
            translate([sx*(x/2-r), sy*(y/2-r), sz*(z/2-r)])
                sphere(r=r);
    }
}

smd_body([6.5,3.5,1.6], 0.4);