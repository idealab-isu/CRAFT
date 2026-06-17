$fn = 128;

// HT 90° pipe, nominal 150 mm
// Assumptions (typical for HT drainage pipe):
// - Nominal OD ~ 160 mm for DN150
// - Wall thickness ~ 4.9 mm
// - Centerline bend radius ~ 150 mm (approx. 1x DN)
// - Straight tangents on both ends ~ 150 mm each

dn = 150;                 // nominal
od = 160;                 // outer diameter (mm), typical for DN150 HT
wall = 4.9;               // wall thickness (mm)
id = od - 2*wall;

bend_angle = 90;          // degrees
R = 150;                  // centerline radius (mm)
tangent = 150;            // straight length each end (mm)

module torus_segment(angle=90, R=150, r=10) {
    rotate_extrude(angle=angle, convexity=10)
        translate([R, 0, 0])
            circle(r=r);
}

module ht_90_pipe_dn150() {
    difference() {
        union() {
            // Bend (outer)
            torus_segment(angle=bend_angle, R=R, r=od/2);

            // Straight tangents (outer)
            // Start tangent along +X from the bend start (at angle 0)
            translate([R, 0, 0])
                rotate([0, 90, 0])
                    cylinder(h=tangent, r=od/2, center=false);

            // End tangent along +Y from the bend end (at angle 90)
            translate([0, R, 0])
                rotate([-90, 0, 0])
                    cylinder(h=tangent, r=od/2, center=false);
        }

        union() {
            // Bend (inner)
            torus_segment(angle=bend_angle, R=R, r=id/2);

            // Straight tangents (inner)
            translate([R, 0, 0])
                rotate([0, 90, 0])
                    cylinder(h=tangent + 0.2, r=id/2, center=false);

            translate([0, R, 0])
                rotate([-90, 0, 0])
                    cylinder(h=tangent + 0.2, r=id/2, center=false);
        }
    }
}

ht_90_pipe_dn150();