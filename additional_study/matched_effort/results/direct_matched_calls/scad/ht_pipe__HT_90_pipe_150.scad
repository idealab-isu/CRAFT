$fn = 128;

// HT 90° pipe, nominal DN150 (approx). Units: mm.
// Simple parametric elbow: outer/inner torus segment with straight stubs.

dn = 150;                 // nominal diameter
wall = 4.5;               // typical HT wall thickness (approx)
OD = 160;                 // approximate outer diameter for DN150 HT
ID = OD - 2*wall;

bend_angle = 90;          // degrees
centerline_radius = 150;  // bend radius to pipe centerline (approx)
stub_len = 60;            // straight length on each end

module elbow_segment(OD, ID, R, ang){
    difference(){
        rotate_extrude(angle=ang, convexity=10)
            translate([R,0,0]) circle(d=OD);
        rotate_extrude(angle=ang, convexity=10)
            translate([R,0,0]) circle(d=ID);
    }
}

module straight_pipe(OD, ID, L){
    difference(){
        cylinder(d=OD, h=L, center=false);
        translate([0,0,-0.1]) cylinder(d=ID, h=L+0.2, center=false);
    }
}

module ht_90_dn150(){
    // Elbow in XY plane, starting along +X and ending along +Y.
    union(){
        // Bend
        elbow_segment(OD, ID, centerline_radius, bend_angle);

        // Stub at start (along +X): place at angle 0 tangent point
        // Tangent point at (R,0). Tangent direction is +Y, but we want stub along +X axis direction.
        // For a rotate_extrude elbow, the pipe axis follows the swept circle; tangents are along +Y at angle 0.
        // We'll instead add stubs aligned with the local tangent directions:
        // Start tangent: +Y at (R,0)
        translate([centerline_radius, 0, 0])
            rotate([90,0,0])  // cylinder along +Y
                straight_pipe(OD, ID, stub_len);

        // Stub at end (angle 90): point at (0,R), tangent is -X
        translate([0, centerline_radius, 0])
            rotate([0,0,180]) // flip to +X then rotate to align with -X tangent via next rotate
            rotate([0,90,0])  // cylinder along +X
                straight_pipe(OD, ID, stub_len);
    }
}

ht_90_dn150();