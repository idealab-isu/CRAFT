$fn=96;

L = 100;
W = 40;
H = 24;

cut_r = 16;
cut_z = 0;

prong_len = 40;
prong_gap = 14;
prong_thk = 8;
prong_h = 18;

hole_d = 6;
hole_offset = 38;

chamfer = 3;

module chamfered_box(size=[10,10,10], c=2){
    sx=size[0]; sy=size[1]; sz=size[2];
    intersection(){
        cube([sx,sy,sz], center=true);
        union(){
            cube([sx-2*c, sy, sz], center=true);
            cube([sx, sy-2*c, sz], center=true);
            cube([sx, sy, sz-2*c], center=true);
            rotate([0,0,45]) cube([sx*1.2, sy-2*c, sz-2*c], center=true);
            rotate([0,0,45]) cube([sx-2*c, sy*1.2, sz-2*c], center=true);
            rotate([0,0,45]) cube([sx-2*c, sy-2*c, sz*1.2], center=true);
        }
    }
}

module prong(xc, yc){
    translate([xc, yc, 0])
        chamfered_box([prong_len, prong_thk, prong_h], c=chamfer);
}

module body(){
    union(){
        chamfered_box([L, W, H], c=chamfer);

        // Two prongs extending from +X side
        prong(L/2 + prong_len/2 - chamfer,  (prong_gap/2 + prong_thk/2));
        prong(L/2 + prong_len/2 - chamfer, -(prong_gap/2 + prong_thk/2));
    }
}

module internal_cutout(){
    // Large semicircular internal cutout (cylindrical along X), open to -Y side
    translate([0, -W/2 + cut_r + 2, cut_z])
        rotate([0,90,0])
            cylinder(h=L + prong_len + 10, r=cut_r, center=true);
}

module fork_opening(){
    // Remove material between prongs to create fork opening
    translate([L/2 + prong_len/2 - chamfer, 0, 0])
        cube([prong_len + 2, prong_gap, prong_h + 2], center=true);
}

module end_hole(xpos){
    // Through-hole along Y, appears diamond-shaped when viewed at angle by rotating square profile
    translate([xpos, 0, 0])
        rotate([90,0,0])
            rotate([0,0,45])
                cylinder(h=W + 20, r=hole_d/2, center=true, $fn=4);
}

difference(){
    body();
    internal_cutout();
    fork_opening();
    end_hole(-hole_offset);
    end_hole( hole_offset);
}