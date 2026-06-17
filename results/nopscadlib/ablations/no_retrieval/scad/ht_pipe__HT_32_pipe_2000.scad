// HT pipe: HT 32, length 2000 mm
// One connected solid, readable in orthographic views (pipe axis along X)

// Parameters
pipe_length = 2000;                 //[1000:4000:10]
outer_diameter = 32;                //[16:64:1]
wall_thickness = 2;                 //[1:4:0.1]

socket_length = 50;                 //[25:100:1]
socket_outer_diameter = 40;         //[34:60:1]
socket_wall_thickness = 2.5;        //[1.5:5:0.1]

chamfer_length = 2;                 //[1:6:0.5]
overlap = 1;                        //[0.5:2:0.1]
$fn = 128;

// Derived radii
r_pipe_o   = outer_diameter/2;
r_pipe_i   = r_pipe_o - wall_thickness;

r_sock_o   = socket_outer_diameter/2;
r_sock_i   = r_sock_o - socket_wall_thickness;

// Guards
wall_ok = (r_pipe_i > 0) && (r_sock_i > 0);
ch_ok   = chamfer_length > 0;

// Helpers: cylinders along X axis
module cylx(h, r, center=true) rotate([0,90,0]) cylinder(h=h, r=r, center=center);
module cylx_taper(h, r1, r2, center=true) rotate([0,90,0]) cylinder(h=h, r1=r1, r2=r2, center=center);

// Main model
module ht_pipe_32() {
    // Place socket on +X end, plain end on -X end
    x_socket_center =  pipe_length/2 - socket_length/2 + overlap;
    x_plain_end     = -pipe_length/2;
    x_socket_end    =  pipe_length/2;

    difference() {
        // OUTER SOLID (connected)
        union() {
            // Main pipe OD
            cylx(pipe_length, r_pipe_o, center=true);

            // Socket OD (overlaps into main pipe by "overlap" to ensure connectivity)
            translate([x_socket_center, 0, 0])
                cylx(socket_length, r_sock_o, center=true);
        }

        // INNER VOID (single connected subtraction)
        union() {
            // Main bore
            if (wall_ok)
                cylx(pipe_length + 2*overlap, r_pipe_i, center=true);

            // Socket bore
            if (wall_ok)
                translate([x_socket_center, 0, 0])
                    cylx(socket_length + 2*overlap, r_sock_i, center=true);

            // Plain-end chamfer (removes a small wedge from the end)
            if (ch_ok && wall_ok)
                translate([x_plain_end + chamfer_length/2 - overlap, 0, 0])
                    cylx_taper(chamfer_length + 2*overlap, r1=r_pipe_o, r2=r_pipe_i, center=true);

            // Socket-end chamfer (outer mouth of socket)
            if (ch_ok && wall_ok)
                translate([x_socket_end - chamfer_length/2 + overlap, 0, 0])
                    cylx_taper(chamfer_length + 2*overlap, r1=r_sock_o, r2=r_sock_i, center=true);
        }
    }
}

color("Silver") ht_pipe_32();