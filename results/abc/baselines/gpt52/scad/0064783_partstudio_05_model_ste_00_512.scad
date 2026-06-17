$fn=64;

th = 0.6;

module chamfered_strap(L=90, W=12, cham=6) {
    polygon(points=[
        [-L/2+cham, -W/2],
        [ L/2-cham, -W/2],
        [ L/2, 0],
        [ L/2-cham,  W/2],
        [-L/2+cham,  W/2],
        [-L/2, 0]
    ]);
}

module diamond_hole(s=6) {
    rotate(45) square([s, s], center=true);
}

module tri_hole(s=7) {
    polygon(points=[
        [0,  s*0.57735],
        [-s/2, -s*0.288675],
        [ s/2, -s*0.288675]
    ]);
}

module strap_with_holes(L=90, W=12, cham=6) {
    difference() {
        chamfered_strap(L=L, W=W, cham=cham);
        for (i=[-3:3]) {
            x = i*(L/7.5);
            if (i%3==0)
                translate([x,0]) diamond_hole(s=6);
            else if (i%3==1)
                translate([x,0]) square([5.5,5.5], center=true);
            else
                translate([x,0]) tri_hole(s=7);
        }
        for (i=[-2:2]) {
            translate([i*(L/6.5), 0]) circle(d=3.2);
        }
    }
}

module rail_notched(L=95, W=10, tooth=6, depth=3) {
    difference() {
        square([L, W], center=true);
        n = floor(L/tooth);
        for (i=[0:n-1]) {
            x = -L/2 + tooth/2 + i*tooth;
            translate([x, W/2 - depth/2]) square([tooth*0.7, depth], center=true);
        }
        for (i=[-3:3]) {
            translate([i*(L/7.0), 0]) circle(d=3.0);
        }
    }
}

module spool_block(L=18, W=10) {
    union() {
        square([L, W], center=true);
        square([L*0.45, W*1.6], center=true);
        translate([-L*0.25,0]) circle(d=W*0.9);
        translate([ L*0.25,0]) circle(d=W*0.9);
    }
}

module plate_assembly_2d() {
    union() {
        translate([-55, 18]) strap_with_holes(L=92, W=12, cham=6);
        translate([-55, -2]) strap_with_holes(L=92, W=12, cham=6);

        translate([35, 18]) rail_notched(L=98, W=10, tooth=6, depth=3);
        translate([35, 4])  rail_notched(L=98, W=10, tooth=6, depth=3);

        translate([35, -16]) spool_block(L=18, W=10);
    }
}

scale([0.001, 0.001, 1])
linear_extrude(height=th, center=true)
plate_assembly_2d();