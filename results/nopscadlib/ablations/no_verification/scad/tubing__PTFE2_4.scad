// PTFE Tubing (round, hollow cylinder) - fixed centering/visibility

// Parameters
length = 15; //[7.5:30:0.5]
od = 4;      //[2:8:0.1]
id = 2;      //[1:4:0.1]
center = 1;  //[0:1]

$fn = 96; // smooth round tube

module ptfe_tube(len, od, id, centered=true) {
    outer_r = max(0.01, od/2);
    inner_r = min(max(0, id/2), outer_r - 0.01); // ensure non-zero wall
    eps = 0.2;

    color([0.85, 0.85, 0.8])  // off-white PTFE
    difference() {
        cylinder(h=len, r=outer_r, center=centered);
        cylinder(h=len + eps, r=inner_r, center=centered);
    }
}

// Place tube so it is visible whether centered or not
translate([0, 0, center ? 0 : length/2])
    ptfe_tube(length, od, id, centered= (center == 1));