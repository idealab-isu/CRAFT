$fn=64;

L = 120;
W = 22;
T = 8;

midL = 44;
midW = 28;
midT = 12;

endChamfer = 10;

holeD = 6;
holeInset = 12;

winL = 34;
winW = 12;
winR = 3;
winZ = 0;

win1x = -22;
win2x = 22;

module rounded_box(size=[10,10,10], r=2, center=true){
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, min(sx, sy)/2);
    translate(center ? [-sx/2, -sy/2, -sz/2] : [0,0,0])
    linear_extrude(height=sz)
        offset(r=rr)
            offset(delta=-rr)
                square([sx, sy], center=false);
}

module capsule2d(len=20, wid=10){
    r = wid/2;
    hull(){
        translate([-len/2 + r, 0]) circle(r=r);
        translate([ len/2 - r, 0]) circle(r=r);
    }
}

module window_cut(len=30, wid=10, r=2, h=50){
    linear_extrude(height=h, center=true)
        offset(r=r)
            offset(delta=-r)
                capsule2d(len=len, wid=wid);
}

module end_hole(xpos){
    translate([xpos, 0, 0])
        rotate([90,0,0])
            cylinder(d=holeD, h=200, center=true);
}

module chamfer_ends(){
    union(){
        translate([ L/2 - endChamfer/2, 0, 0])
            rotate([0,45,0])
                cube([endChamfer*2, W*3, T*3], center=true);
        translate([-L/2 + endChamfer/2, 0, 0])
            rotate([0,-45,0])
                cube([endChamfer*2, W*3, T*3], center=true);
    }
}

module mid_facets(){
    union(){
        translate([0, 0, 0])
            hull(){
                translate([-midL/2, 0, 0]) rounded_box([midL*0.55, midW, midT], r=4, center=true);
                translate([ midL/2, 0, 0]) rounded_box([midL*0.55, midW, midT], r=4, center=true);
            }
        translate([0, 0, 0])
            hull(){
                translate([-midL/2, 0, 0]) rounded_box([midL*0.35, midW*0.85, midT*1.15], r=3, center=true);
                translate([ midL/2, 0, 0]) rounded_box([midL*0.35, midW*0.85, midT*1.15], r=3, center=true);
            }
    }
}

module main_body(){
    union(){
        hull(){
            translate([-L/2 + endChamfer, 0, 0]) rounded_box([W, W, T], r=5, center=true);
            translate([ L/2 - endChamfer, 0, 0]) rounded_box([W, W, T], r=5, center=true);
        }
        mid_facets();
    }
}

difference(){
    intersection(){
        main_body();
        difference(){
            cube([L*2, W*4, T*4], center=true);
            chamfer_ends();
        }
    }

    translate([win1x, 0, winZ]) window_cut(len=winL, wid=winW, r=winR, h=T*4);
    translate([win2x, 0, winZ]) window_cut(len=winL, wid=winW, r=winR, h=T*4);

    end_hole(-L/2 + holeInset);
    end_hole( L/2 - holeInset);

    translate([0, 0, 0])
        rotate([0,0,0])
            linear_extrude(height=T*4, center=true)
                polygon(points=[
                    [-midL/2, 0],
                    [-midL/2 + 10,  midW/2 + 6],
                    [ midL/2 - 10,  midW/2 + 6],
                    [ midL/2, 0],
                    [ midL/2 - 10, -midW/2 - 6],
                    [-midL/2 + 10, -midW/2 - 6]
                ]);
}