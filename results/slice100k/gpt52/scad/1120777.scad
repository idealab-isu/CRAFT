$fn=96;

L = 44.4;
W = 7.6;
T = 2.5;

hole_d = 3.2;
end_offset = 6.0;

module capsule2d(len, wid){
    r = wid/2;
    hull(){
        translate([-(len/2 - r), 0]) circle(r=r);
        translate([ (len/2 - r), 0]) circle(r=r);
    }
}

module link_plate(){
    difference(){
        linear_extrude(height=T, center=true)
            capsule2d(L, W);

        for (sx = [-1, 1]){
            translate([sx*(L/2 - end_offset), 0, 0])
                cylinder(h=T+0.6, d=hole_d, center=true);
        }
    }
}

link_plate();