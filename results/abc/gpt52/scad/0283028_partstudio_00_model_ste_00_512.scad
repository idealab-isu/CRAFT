$fn=64;

L = 100;
W = 40;
H = 20;

cut_L = 70;
cut_W = 24;
cut_H = 14;

end_block_L = (L - cut_L)/2;

hole_d = 6;
cbore_d = 12;
cbore_h = 6;

edge_ch = 1.2;

hole_offset_x = 10;
hole_offset_y = 10;

module chamfered_box(size=[10,10,10], ch=1){
    sx=size[0]; sy=size[1]; sz=size[2];
    intersection(){
        cube([sx,sy,sz], center=true);
        minkowski(){
            cube([max(0.01,sx-2*ch), max(0.01,sy-2*ch), max(0.01,sz-2*ch)], center=true);
            octa = polyhedron(
                points=[
                    [ ch, 0, 0], [-ch, 0, 0],
                    [ 0, ch, 0], [ 0,-ch, 0],
                    [ 0, 0, ch], [ 0, 0,-ch]
                ],
                faces=[
                    [0,2,4],[2,1,4],[1,3,4],[3,0,4],
                    [2,0,5],[1,2,5],[3,1,5],[0,3,5]
                ]
            );
            octa;
        }
    }
}

module counterbored_through_hole(thickness, d_through, d_cbore, h_cbore){
    union(){
        cylinder(h=thickness+0.2, d=d_through, center=true);
        translate([0,0, thickness/2 - h_cbore/2 + 0.01])
            cylinder(h=h_cbore+0.2, d=d_cbore, center=true);
    }
}

module end_holes(){
    for(side=[-1,1]){
        x_center = side*(L/2 - hole_offset_x);
        y_center = side*(W/2 - hole_offset_y);
        translate([x_center, y_center, 0])
            counterbored_through_hole(H, hole_d, cbore_d, cbore_h);
    }
}

difference(){
    chamfered_box([L,W,H], edge_ch);

    translate([0,0,0])
        cube([cut_L, cut_W, cut_H], center=true);

    end_holes();
}