$fn=64;

L = 100;
W = 30;
T = 3;

corner_r = 6;

step_len = 70;
step_w = 6;
step_h = 1.2;

chamfer_block_len = 10;
chamfer_block_w = 10;
chamfer_block_h = 1.2;
chamfer = 3;

module rounded_rect_2d(l, w, r){
    hull(){
        translate([ l/2 - r,  w/2 - r]) circle(r=r);
        translate([-l/2 + r,  w/2 - r]) circle(r=r);
        translate([ l/2 - r, -w/2 + r]) circle(r=r);
        translate([-l/2 + r, -w/2 + r]) circle(r=r);
    }
}

module plate_body(){
    linear_extrude(height=T)
        rounded_rect_2d(L, W, corner_r);
}

module stepped_base(){
    translate([0, -W/2 + step_w/2, -step_h])
        cube([step_len, step_w, step_h], center=true);
}

module chamfer_block(signx=1){
    x0 = signx*(L/2 - chamfer_block_len/2);
    y0 = -W/2 + chamfer_block_w/2;
    translate([x0, y0, -chamfer_block_h])
    difference(){
        cube([chamfer_block_len, chamfer_block_w, chamfer_block_h], center=true);
        translate([signx*(chamfer_block_len/2 - chamfer/2), chamfer_block_w/2 - chamfer/2, 0])
            rotate([0,0,45])
                cube([chamfer*2, chamfer*2, chamfer_block_h+0.2], center=true);
    }
}

module hex_slot_2d(len=18, w=6){
    r = w/2;
    hull(){
        translate([-len/2 + r, 0]) circle(r=r, $fn=6);
        translate([ len/2 - r, 0]) circle(r=r, $fn=6);
    }
}

module diamond_2d(w=8, h=8){
    polygon(points=[[0,h/2],[w/2,0],[0,-h/2],[-w/2,0]]);
}

module tri_2d(s=8){
    polygon(points=[[0,s/2],[-s/2,-s/2],[s/2,-s/2]]);
}

module cutouts(){
    union(){
        for (yy = [-6, 6]){
            for (xx = [-30, -10, 10, 30]){
                translate([xx, yy, -0.2])
                    linear_extrude(height=T+0.4)
                        hex_slot_2d(len=18, w=6);
            }
        }

        for (xx = [-20, 20]){
            translate([xx, 0, -0.2])
                linear_extrude(height=T+0.4)
                    diamond_2d(w=9, h=9);
        }

        for (p = [[-40, 0, 0], [40, 0, 180], [-5, 12, 0], [5, -12, 180]]){
            translate([p[0], p[1], -0.2])
                rotate([0,0,p[2]])
                    linear_extrude(height=T+0.4)
                        tri_2d(s=8);
        }
    }
}

difference(){
    union(){
        plate_body();
        stepped_base();
        chamfer_block(1);
        chamfer_block(-1);
    }
    cutouts();
}