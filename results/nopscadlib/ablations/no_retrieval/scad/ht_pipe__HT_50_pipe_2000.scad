// HT 50 pipe, 2000 mm length (single connected solid)
// Fix: orient pipe along X so Front/Back/Left/Right views show the full length

$fn = 128;

// Parameters
pipe_length = 2000;                 //[1000:4000:10]
outer_diameter = 50;                //[25:100:1]
wall_thickness = 1.8;               //[0.9:3.6:0.1]

socket_length = 60;                 //[30:120:1]
socket_outer_diameter = 56;         //[52:70:1]
socket_wall_thickness = 2.2;        //[1.2:4.4:0.1]

overlap = 1;                        //[0.5:2:0.1]
chamfer_length = 2;                 //[1:6:0.5]
chamfer_radial = 1;                 //[0.5:3:0.1]

// Derived radii
r_pipe_o   = outer_diameter/2;
r_pipe_i   = r_pipe_o - wall_thickness;

r_sock_o   = socket_outer_diameter/2;
r_sock_i   = r_sock_o - socket_wall_thickness;

// Safety (avoid invalid geometry)
r_pipe_i_ok = max(0.01, r_pipe_i);
r_sock_i_ok = max(0.01, r_sock_i);

// X positions (all formula-based) - pipe axis is X
x_pipe_center   = 0;
x_sock_center   = pipe_length/2 - socket_length/2 + overlap;

x_plain_end     = -pipe_length/2;
x_socket_mouth  =  pipe_length/2;

module outer_solid() {
    union() {
        // Main pipe OD (axis X)
        rotate([0, 90, 0])
            cylinder(h=pipe_length, r=r_pipe_o, center=true);

        // Socket OD (overlaps into pipe by 'overlap' to guarantee connectivity)
        translate([x_sock_center, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=socket_length, r=r_sock_o, center=true);
    }
}

module inner_voids() {
    union() {
        // Main bore (slightly longer to ensure clean subtraction)
        rotate([0, 90, 0])
            cylinder(h=pipe_length + 4*overlap, r=r_pipe_i_ok, center=true);

        // Socket bore (slightly longer to ensure clean subtraction)
        translate([x_sock_center, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=socket_length + 4*overlap, r=r_sock_i_ok, center=true);
    }
}

module chamfer_voids() {
    union() {
        // Plain end outer chamfer (remove material)
        translate([x_plain_end + chamfer_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=chamfer_length + 2*overlap,
                         r1=r_pipe_o + overlap,
                         r2=max(0.01, r_pipe_o - chamfer_radial),
                         center=true);

        // Plain end inner chamfer (remove material)
        translate([x_plain_end + chamfer_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=chamfer_length + 2*overlap,
                         r1=max(0.01, r_pipe_i_ok + chamfer_radial),
                         r2=max(0.01, r_pipe_i_ok),
                         center=true);

        // Socket mouth outer chamfer (remove material)
        translate([x_socket_mouth - chamfer_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=chamfer_length + 2*overlap,
                         r1=r_sock_o + overlap,
                         r2=max(0.01, r_sock_o - chamfer_radial),
                         center=true);

        // Socket mouth inner chamfer (remove material)
        translate([x_socket_mouth - chamfer_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=chamfer_length + 2*overlap,
                         r1=max(0.01, r_sock_i_ok + chamfer_radial),
                         r2=max(0.01, r_sock_i_ok),
                         center=true);
    }
}

difference() {
    outer_solid();
    inner_voids();
    chamfer_voids();
}