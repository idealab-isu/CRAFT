// Miniature linear guide rail (single connected solid)
// Target overall size: 100mm long, 5.0mm wide, 3.6mm tall

$fn = 64;

// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 5.0;   //[2.5:10.0:0.1]
rail_H = 3.6;   //[1.8:7.2:0.1]

hole_d = 2.0;       //[1.0:4.0:0.1]
hole_count = 4;     //[2:8:1]
end_margin = 10.0;  //[5.0:20.0:1]

edge_chamfer = 0.4; //[0.2:1.0:0.05]
end_chamfer  = 0.6; //[0.2:1.5:0.05]
overlap = 0.8;      //[0.5:2.0:0.1]

// Linear guide rail profile features (raceways)
race_r = 0.75;        //[0.3:1.2:0.05]  // radius of raceway groove
race_depth = 0.45;    //[0.2:0.9:0.05]  // how deep into side wall
race_z = 0.55;        //[0.2:1.2:0.05]  // vertical offset from center to groove center

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rail_body() {
    cube([rail_L, rail_W, rail_H], center=true);
}

// Through holes along Y (top-to-bottom in typical rail mounting)
module mounting_holes() {
    // Ensure margins are valid
    usable = max(0, rail_L - 2*end_margin);
    step = (hole_count > 1) ? (usable/(hole_count-1)) : 0;

    for (i = [0:hole_count-1]) {
        x = -rail_L/2 + end_margin + i*step;
        translate([x, 0, 0])
            rotate([90, 0, 0])
                cylinder(h=rail_W + 2*overlap, r=hole_d/2, center=true);
    }
}

// Edge chamfers: subtract long wedges at the 4 long edges
module edge_chamfers() {
    // Wedge size: long in X, small in Y/Z
    // Place at each edge and rotate 45 degrees to create a bevel
    for (sy = [-1, 1], sz = [-1, 1]) {
        translate([0,
                   sy*(rail_W/2 - edge_chamfer/2),
                   sz*(rail_H/2 - edge_chamfer/2)])
            rotate([0, 0, sy*sz*45])
                cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
    }
}

// End chamfers: subtract wedges at both ends
module end_chamfers() {
    for (sx = [-1, 1], sz = [-1, 1]) {
        translate([sx*(rail_L/2 - end_chamfer/2), 0, sz*(rail_H/2 - end_chamfer/2)])
            rotate([0, sx*sz*45, 0])
                cube([end_chamfer, rail_W + 2*overlap, end_chamfer], center=true);
    }
}

// Raceway grooves: subtract two longitudinal cylindrical grooves on the side faces
module raceways() {
    // Keep groove center inside the side wall
    // Side face is at y = +/- rail_W/2. Groove center is inset by race_depth.
    inset = clamp(race_depth, 0.05, rail_W/2 - race_r - 0.05);
    zc = clamp(race_z, 0, rail_H/2 - race_r - 0.05);

    for (sy = [-1, 1], sz = [-1, 1]) {
        translate([0, sy*(rail_W/2 - inset), sz*zc])
            rotate([0, 90, 0])
                cylinder(h=rail_L + 2*overlap, r=race_r, center=true);
    }
}

// Final rail
module rail_complete() {
    difference() {
        rail_body();
        mounting_holes();
        edge_chamfers();
        end_chamfers();
        raceways();
    }
}

color("Silver") rail_complete();