// HT 90° pipe (elbow) with total centerline length = 1500 mm
// One connected solid: outer union, then hollowed with inner union.

$fn = 128;

// Parameters
nominal_size = 90; //[50:160:1]
length_mm = 1500; //[750:3000:10]
end_fitting = 1; //[0:1:1]
pipe_od = 90; //[50:160:1]
pipe_wall = 2.7; //[1.5:6:0.1]
fitting_length = 60; //[30:120:1]
fitting_wall_extra = 1.8; //[0.5:4:0.1]
socket_id_clearance = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]

// Elbow geometry controls
bend_angle = 90;
bend_radius = pipe_od * 1.5; // centerline radius

// Derived
r_outer = pipe_od/2;
r_inner = r_outer - pipe_wall;
r_socket_outer = r_outer + fitting_wall_extra;
r_socket_inner = r_outer + socket_id_clearance;

arc_len = bend_radius * (bend_angle * PI / 180);
leg_len = max(0, (length_mm - arc_len) / 2);

// Elbow made by sweeping a circle around Z; its centerline lies in XY plane.
// At angle 0: point (bend_radius,0,0), tangent +Y
// At angle 90: point (0,bend_radius,0), tangent -X
module elbow_solid(ro) {
    rotate_extrude(angle=bend_angle, convexity=10)
        translate([bend_radius, 0, 0])
            circle(r=ro);
}

module elbow_inner(ri) {
    rotate_extrude(angle=bend_angle + 0.5, convexity=10)
        translate([bend_radius, 0, 0])
            circle(r=ri);
}

module ht90_pipe_1500() {
    color([0.85, 0.85, 0.8])
    difference() {

        // OUTER (connected)
        union() {
            // Elbow
            elbow_solid(r_outer);

            // Leg 1: tangent at elbow start, along +Y from (bend_radius,0,0)
            translate([bend_radius, 0, 0])
                rotate([-90, 0, 0]) // make cylinder axis +Y
                    cylinder(h=leg_len, r=r_outer, center=false);

            // Leg 2: tangent at elbow end, along -X from (0,bend_radius,0)
            translate([0, bend_radius, 0])
                rotate([0, 90, 0])  // make cylinder axis -X
                    cylinder(h=leg_len, r=r_outer, center=false);

            // Optional sockets (outer), overlapped into legs
            if (end_fitting == 1) {
                // Socket on end of leg 1 (+Y end)
                translate([bend_radius, leg_len - overlap, 0])
                    rotate([-90, 0, 0])
                        cylinder(h=fitting_length, r=r_socket_outer, center=false);

                // Socket on end of leg 2 (-X end)
                translate([-(leg_len - overlap), bend_radius, 0])
                    rotate([0, 90, 0])
                        cylinder(h=fitting_length, r=r_socket_outer, center=false);
            }
        }

        // INNER VOID (connected)
        union() {
            // Elbow inner
            elbow_inner(r_inner);

            // Leg 1 inner (+Y)
            translate([bend_radius, -overlap, 0])
                rotate([-90, 0, 0])
                    cylinder(h=leg_len + 2*overlap, r=r_inner, center=false);

            // Leg 2 inner (-X)
            translate([overlap, bend_radius, 0])
                rotate([0, 90, 0])
                    cylinder(h=leg_len + 2*overlap, r=r_inner, center=false);

            // Socket bores (inner) if enabled
            if (end_fitting == 1) {
                // Bore for socket on leg 1
                translate([bend_radius, leg_len - 2*overlap, 0])
                    rotate([-90, 0, 0])
                        cylinder(h=fitting_length + 4*overlap, r=r_socket_inner, center=false);

                // Bore for socket on leg 2
                translate([-(leg_len - 2*overlap), bend_radius, 0])
                    rotate([0, 90, 0])
                        cylinder(h=fitting_length + 4*overlap, r=r_socket_inner, center=false);
            }
        }
    }
}

ht90_pipe_1500();