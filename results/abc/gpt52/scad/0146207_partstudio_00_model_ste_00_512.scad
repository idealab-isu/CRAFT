$fn=64;

plate_x = 200;
plate_y = 300;
plate_t = 2.0;

corner_r = 18;

corner_hole_d = 6.0;
corner_hole_inset = 18;

tab_len = 34;
tab_wid = 22;
tab_t = plate_t;
tab_hole_d = 6.0;

bezel_h = 3.0;
bezel_outer_flat = 120;
bezel_inner_flat = 92;

pocket_x = 70;
pocket_y = 46;
pocket_depth = 1.6;
pocket_r = 3;

module rounded_rect_2d(x,y,r){
    hull(){
        translate([ x/2 - r,  y/2 - r]) circle(r=r);
        translate([-x/2 + r,  y/2 - r]) circle(r=r);
        translate([-x/2 + r, -y/2 + r]) circle(r=r);
        translate([ x/2 - r, -y/2 + r]) circle(r=r);
    }
}

module diamond_2d(len,wid){
    polygon(points=[
        [ len/2, 0],
        [ 0, wid/2],
        [-len/2, 0],
        [ 0,-wid/2]
    ]);
}

module octagon_2d(flat){
    r = flat/(2*cos(180/8));
    circle(r=r, $fn=8);
}

module plate_base(){
    linear_extrude(height=plate_t)
        rounded_rect_2d(plate_x, plate_y, corner_r);
}

module corner_holes(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*(plate_x/2 - corner_hole_inset), sy*(plate_y/2 - corner_hole_inset), -1])
            cylinder(h=plate_t+bezel_h+4, d=corner_hole_d);
    }
}

module tabs(){
    for (sy=[-1,1]){
        translate([0, sy*(plate_y/2), 0])
            linear_extrude(height=tab_t)
                diamond_2d(tab_len, tab_wid);
    }
}

module tab_holes(){
    for (sy=[-1,1]){
        translate([0, sy*(plate_y/2), -1])
            cylinder(h=plate_t+bezel_h+4, d=tab_hole_d);
    }
}

module bezel(){
    difference(){
        translate([0,0,plate_t])
            linear_extrude(height=bezel_h)
                octagon_2d(bezel_outer_flat);
        translate([0,0,plate_t-0.2])
            linear_extrude(height=bezel_h+0.4)
                octagon_2d(bezel_inner_flat);
    }
}

module pocket(){
    translate([0,0,plate_t - pocket_depth])
        linear_extrude(height=pocket_depth+0.2)
            rounded_rect_2d(pocket_x, pocket_y, pocket_r);
}

difference(){
    union(){
        union(){
            plate_base();
            tabs();
        }
        bezel();
    }
    corner_holes();
    tab_holes();
    pocket();
}