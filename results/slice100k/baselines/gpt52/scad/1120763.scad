$fn=96;

L = 60.6;
W = 7.0;
T = 2.5;

end_r = W/2;

big_d = 4.2;
small_d = 1.8;

end_offset = 8.0;

module strap_outline(len=L, wid=W, thick=T){
    linear_extrude(height=thick, center=true)
        hull(){
            translate([-(len/2 - wid/2), 0]) circle(r=wid/2);
            translate([ (len/2 - wid/2), 0]) circle(r=wid/2);
        }
}

module through_hole(d, thick=T){
    cylinder(d=d, h=thick+0.6, center=true);
}

module end_holes(side=1){
    x0 = side*(L/2 - end_offset);

    // Large hole near end
    translate([x0, 0, 0]) through_hole(big_d);

    // Three small holes near end, asymmetrical pattern
    // Pattern mirrored between ends by flipping Y with side
    translate([x0 - side*3.2,  side*1.6, 0]) through_hole(small_d);
    translate([x0 - side*1.0, -side*1.2, 0]) through_hole(small_d);
    translate([x0 - side*4.6, -side*0.2, 0]) through_hole(small_d);
}

difference(){
    strap_outline();
    end_holes(1);
    end_holes(-1);
}