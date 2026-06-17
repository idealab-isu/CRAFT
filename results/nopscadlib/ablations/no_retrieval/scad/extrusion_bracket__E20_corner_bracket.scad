// Clean connected extrusion L-bracket sized [28,28,20]

overall_x = 28; //[14:56:1]
overall_y = 28; //[14:56:1]
overall_z = 20; //[10:40:1]

leg_thk = 3;    //[2:6:1]

hole_d = 5;     //[3:10:1]
hole_edge_offset = 7; //[4:14:1]
hole_spacing = 14;    //[8:28:1]

csk_d = 9;      //[6:18:1]
csk_depth = 2;  //[1:5:1]

inner_relief_r = 4; //[2:10:1]
eps = 0.02;
overlap = 0.6;  //[0.5:2:0.5]

$fn = 64;

function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Hole placement (kept inside faces)
hole_x = clamp(hole_edge_offset, hole_d/2 + 1, overall_x - hole_d/2 - 1);
hole_y = clamp(hole_edge_offset, hole_d/2 + 1, overall_y - hole_d/2 - 1);
hole_z_off = clamp(hole_spacing/2, 0, overall_z/2 - (hole_d/2 + 1));

// Body: union of two legs (no coplanar overlaps that cause artifacts)
module bracket_body() {
    union() {
        // Leg A: along +X, thickness in Y
        translate([overall_x/2, leg_thk/2, overall_z/2])
            cube([overall_x, leg_thk, overall_z], center=true);

        // Leg B: along +Y, thickness in X
        translate([leg_thk/2, overall_y/2, overall_z/2])
            cube([leg_thk, overall_y, overall_z], center=true);
    }
}

// Inner relief: quarter-cylinder removed at inside corner.
// Use intersection with a cube to make it a true quarter-cylinder (prevents stray fragments).
module inner_relief() {
    translate([leg_thk, leg_thk, overall_z/2])
        intersection() {
            cylinder(r=inner_relief_r, h=overall_z + 2*(overlap + eps), center=true);
            translate([inner_relief_r/2, inner_relief_r/2, 0])
                cube([inner_relief_r, inner_relief_r, overall_z + 2*(overlap + eps)], center=true);
        }
}

module holes_leg_a() {
    // Through holes normal to Y (through thickness of leg A)
    for (zv = [-hole_z_off, hole_z_off]) {
        translate([hole_x, leg_thk/2, overall_z/2 + zv])
            rotate([90, 0, 0])
                cylinder(d=hole_d, h=leg_thk + 2*(overlap + eps), center=true);

        // Countersink from outer face (Y = leg_thk)
        translate([hole_x, leg_thk - csk_depth/2, overall_z/2 + zv])
            rotate([90, 0, 0])
                cylinder(d1=csk_d, d2=hole_d, h=csk_depth + (overlap + eps), center=true);
    }
}

module holes_leg_b() {
    // Through holes normal to X (through thickness of leg B)
    for (zv = [-hole_z_off, hole_z_off]) {
        translate([leg_thk/2, hole_y, overall_z/2 + zv])
            rotate([0, 90, 0])
                cylinder(d=hole_d, h=leg_thk + 2*(overlap + eps), center=true);

        // Countersink from outer face (X = leg_thk)
        translate([leg_thk - csk_depth/2, hole_y, overall_z/2 + zv])
            rotate([0, 90, 0])
                cylinder(d1=csk_d, d2=hole_d, h=csk_depth + (overlap + eps), center=true);
    }
}

module all_cuts() {
    union() {
        inner_relief();
        holes_leg_a();
        holes_leg_b();
    }
}

module final_bracket() {
    difference() {
        bracket_body();
        all_cuts();
    }
}

color("Silver") final_bracket();