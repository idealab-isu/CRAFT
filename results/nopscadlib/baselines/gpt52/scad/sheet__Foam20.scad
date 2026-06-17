$fn=64;

module rounded_box(size=[100,60,10], r=3){
    x=size[0]; y=size[1]; z=size[2];
    r2=min(r, min(x,y)/2);
    linear_extrude(height=z, center=true)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

module pore_field(area=[100,60], z=10, n=220, rmin=0.6, rmax=2.2, seed=1234){
    x=area[0]; y=area[1];
    for(i=[0:n-1]){
        xi = rands(-x/2, x/2, 1, seed + i*17)[0];
        yi = rands(-y/2, y/2, 1, seed + i*29)[0];
        ri = rands(rmin, rmax, 1, seed + i*43)[0];
        zi = rands(-z/2, z/2, 1, seed + i*59)[0];
        translate([xi, yi, zi])
            sphere(r=ri);
    }
}

module foam_sponge_sheet(size=[120,80,12], corner_r=4, pores=260){
    difference(){
        rounded_box(size=size, r=corner_r);
        pore_field(area=[size[0]*0.98, size[1]*0.98], z=size[2]*1.05, n=pores, rmin=0.7, rmax=2.6, seed=2026);
    }
}

foam_sponge_sheet(size=[120,80,12], corner_r=4, pores=260);