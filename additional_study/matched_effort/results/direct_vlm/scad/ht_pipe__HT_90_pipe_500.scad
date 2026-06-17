$fn = 128;

// HT 90 (90-degree elbow) pipe, overall leg length 500 mm (approximation)
// Typical HT DN90: OD ~ 90 mm, wall ~ 2.7 mm
od = 90;
wall = 2.7;
id = od - 2*wall;

leg_len = 500;          // length of each straight leg from elbow tangent to end
bend_angle = 90;        // degrees
bend_r_center = 120;    // centerline bend radius (approx), adjust as needed

eps = 0.2;

// ---- helpers ----
module tube_straight(L, d_out, d_in) {
    difference() {
        cylinder(h=L, d=d_out, center=false);
        translate([0,0,-eps]) cylinder(h=L+2*eps, d=d_in, center=false);
    }
}

module tube_bend(angle, r_center, d_out, d_in) {
    // Bend lies in XY plane, centered at origin, starting along +X and ending along +Y
    difference() {
        rotate_extrude(angle=angle, convexity=10)
            translate([r_center, 0, 0]) circle(d=d_out);
        rotate_extrude(angle=angle, convexity=10)
            translate([r_center, 0, 0]) circle(d=d_in);
    }
}

// ---- build one connected solid ----
union() {
    // 90° bend (in XY plane)
    tube_bend(bend_angle, bend_r_center, od, id);

    // Straight leg along +X from bend tangent at angle 0°
    translate([bend_r_center, 0, 0])
        rotate([0, 90, 0])
            tube_straight(leg_len, od, id);

    // Straight leg along +Y from bend tangent at angle 90°
    translate([0, bend_r_center, 0])
        rotate([-90, 0, 0])
            tube_straight(leg_len, od, id);
}