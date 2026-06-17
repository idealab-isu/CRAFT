$fn=96;

L = 102.0;
W = 7.0;
T = 3.5;

hole_d = 3.2;
end_margin = 6.0;
hole_offset = L/2 - end_margin;

module rounded_bar_2d(len, wid){
    r = wid/2;
    hull(){
        translate([-len/2 + r, 0]) circle(r=r);
        translate([ len/2 - r, 0]) circle(r=r);
    }
}

module strap(){
    difference(){
        linear_extrude(height=T, center=true)
            rounded_bar_2d(L, W);

        for (sx = [-1, 1]){
            translate([sx*hole_offset, 0, 0])
                cylinder(d=hole_d, h=T+1.0, center=true);
        }
    }
}

strap();