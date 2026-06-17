$fn=64;

module smd_body(size=[9.90, 3.90, 1.25], corner_r=0.35) {
    x=size[0]; y=size[1]; z=size[2];
    r=min(corner_r, x/2, y/2);
    translate([0,0,0])
    linear_extrude(height=z, center=true)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

smd_body([9.90, 3.90, 1.25], 0.35);