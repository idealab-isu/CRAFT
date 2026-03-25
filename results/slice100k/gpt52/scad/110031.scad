$fn=96;

bbox = [11.0, 18.9, 8.8];

stem_d = 8.8;
stem_r = stem_d/2;
stem_len = 18.9;

barrel_d = 6.0;
barrel_r = barrel_d/2;
barrel_len = 11.0;

collar_d = 7.6;
collar_r = collar_d/2;
collar_thk = 2.2;

flange_thk = 1.2;
flange_w = 8.8;
flange_h = 8.8;

prong_len = 3.6;
slot_w = 2.2;
prong_gap = slot_w;
prong_thk = (barrel_d - prong_gap)/2;

chamfer = 0.9;

module stem() {
    rotate([90,0,0]) cylinder(h=stem_len, r=stem_r, center=true);
}

module collar() {
    rotate([0,90,0]) cylinder(h=collar_thk, r=collar_r, center=true);
}

module barrel_main() {
    rotate([0,90,0]) cylinder(h=barrel_len, r=barrel_r, center=true);
}

module flange_plate() {
    translate([-(barrel_len/2 + flange_thk/2), 0, 0])
        cube([flange_thk, flange_w, flange_h], center=true);
}

module prong_chamfer_wedge(len, thk, h, cham) {
    polyhedron(
        points=[
            [0, -thk/2, -h/2],
            [0,  thk/2, -h/2],
            [0,  thk/2,  h/2],
            [0, -thk/2,  h/2],
            [len, -thk/2, -h/2],
            [len,  thk/2, -h/2],
            [len,  thk/2,  h/2],
            [len, -thk/2,  h/2],
            [len, -thk/2, -h/2 + cham],
            [len,  thk/2, -h/2 + cham],
            [len,  thk/2,  h/2 - cham],
            [len, -thk/2,  h/2 - cham]
        ],
        faces=[
            [0,1,2,3],
            [4,5,6,7],
            [0,4,8,3],
            [1,2,10,9],
            [3,8,11,2],
            [0,1,5,4],
            [4,5,9,8],
            [7,6,10,11],
            [8,9,10,11]
        ],
        convexity=10
    );
}

module prong(len, thk, h, cham) {
    difference() {
        cube([len, thk, h], center=false);
        translate([len-cham, 0, 0])
            prong_chamfer_wedge(cham, thk, h, cham);
    }
}

module split_prongs() {
    x0 = barrel_len/2 - prong_len;
    y_off = (prong_gap/2 + prong_thk/2);
    translate([x0, 0, 0]) {
        translate([0,  y_off - prong_thk/2, -barrel_d/2])
            prong(prong_len, prong_thk, barrel_d, chamfer);
        translate([0, -y_off - prong_thk/2, -barrel_d/2])
            prong(prong_len, prong_thk, barrel_d, chamfer);
    }
}

module barrel_with_features() {
    difference() {
        union() {
            barrel_main();
            collar();
            flange_plate();
            split_prongs();
        }
        translate([barrel_len/2 - prong_len/2, 0, 0])
            cube([prong_len + 0.2, prong_gap, barrel_d + 0.4], center=true);
        translate([barrel_len/2 - prong_len/2, 0, 0])
            rotate([0,90,0]) cylinder(h=prong_len + 0.4, r=barrel_r + 0.25, center=true);
    }
}

module fitting() {
    union() {
        stem();
        barrel_with_features();
    }
}

fitting();