$fn = 128;

// HT pipe: nominal DN75, length 150 mm
// Approximations (typical): OD 75 mm, wall 2.7 mm
dn = 75;
L  = 150;

od = 75;
wall = 2.7;
id = od - 2*wall;

module ht_pipe(od, id, L){
    difference(){
        cylinder(h=L, d=od);
        translate([0,0,-0.5])
            cylinder(h=L+1, d=id);
    }
}

ht_pipe(od=od, id=id, L=L);