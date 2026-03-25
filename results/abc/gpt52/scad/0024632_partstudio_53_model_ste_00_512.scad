$fn=96;

plate_th = 6;

body_len = 120;
body_w   = 30;

flange_len = 40;
flange_w   = 60;

total_len = body_len + flange_len;

chamfer = 10;

hole_d = 6.5;
hole_edge_x = 10;
hole_edge_y = 10;

emboss_depth = 0.8;
emboss_th = 1.2;

module stepped_outline_2d() {
    union() {
        translate([-total_len/2, -body_w/2]) square([body_len, body_w], center=false);
        translate([ total_len/2 - flange_len, -flange_w/2]) square([flange_len, flange_w], center=false);
    }
}

module chamfered_end_2d() {
    // subtract two right triangles at the far (non-flange) end corners
    union() {
        // top corner
        translate([-total_len/2, body_w/2 - chamfer])
            polygon(points=[[0,0],[chamfer,0],[0,chamfer]]);
        // bottom corner
        translate([-total_len/2, -body_w/2])
            polygon(points=[[0,0],[chamfer,0],[0,chamfer]]);
    }
}

module base_plate() {
    difference() {
        linear_extrude(height=plate_th, center=true)
            difference() {
                stepped_outline_2d();
                chamfered_end_2d();
            }

        // flange holes
        for (sy = [-1, 1]) {
            translate([ total_len/2 - hole_edge_x, sy*(flange_w/2 - hole_edge_y), 0])
                cylinder(h=plate_th+2, d=hole_d, center=true);
        }
    }
}

module v_feature_2d(len=34, w=18, t=emboss_th) {
    // V/arrow made from two rotated rectangles
    union() {
        translate([0,0]) rotate(30) square([len, t], center=true);
        translate([0,0]) rotate(-30) square([len, t], center=true);
        // small tail
        translate([-len*0.18,0]) square([len*0.25, t], center=true);
    }
}

module face_features(mode="recess") {
    // mode: "recess" subtracts; "emboss" adds
    zpos = plate_th/2 - emboss_depth/2;

    // positions along length: one on body, one on flange
    positions = [
        [-total_len/2 + 55, 0, 0],
        [ total_len/2 - 20, 0, 0]
    ];

    if (mode == "recess") {
        for (p = positions) {
            translate([p[0], p[1],  zpos])
                linear_extrude(height=emboss_depth, center=true)
                    v_feature_2d();
            translate([p[0], p[1], -zpos])
                linear_extrude(height=emboss_depth, center=true)
                    v_feature_2d();
        }
    } else {
        for (p = positions) {
            translate([p[0], p[1],  plate_th/2 + emboss_depth/2])
                linear_extrude(height=emboss_depth, center=true)
                    v_feature_2d();
            translate([p[0], p[1], -plate_th/2 - emboss_depth/2])
                linear_extrude(height=emboss_depth, center=true)
                    v_feature_2d();
        }
    }
}

difference() {
    base_plate();
    face_features("recess");
}