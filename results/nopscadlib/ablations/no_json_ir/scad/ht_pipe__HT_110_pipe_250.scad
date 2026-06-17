// HT 110 pipe segment (OD 110 mm, length 250 mm) with integrated socket/bell
pipe_outer_diameter = 110;   // mm
pipe_wall_thickness = 3.2;   // mm
pipe_length = 250;           // mm

socket_length = 20;          // mm
socket_extra_diameter = 5;   // mm (OD increase at socket)
overlap = 0.5;               // mm (ensures watertight boolean)

$fn = 180;

module ht_pipe_with_socket(od, wall, len, sock_len, sock_extra_d, ov) {
    id = od - 2*wall;
    socket_od = od + sock_extra_d;

    // One connected solid: outer union, inner void subtracted once
    difference() {
        union() {
            // Main outer cylinder
            cylinder(h=len, d=od, center=false);

            // Socket outer sleeve at one end, connected by computed placement + overlap
            translate([0, 0, len - sock_len - ov])
                cylinder(h=sock_len + ov, d=socket_od, center=false);
        }

        // Inner void through the full pipe length (slightly extended for clean subtraction)
        translate([0, 0, -ov])
            cylinder(h=len + 2*ov, d=id, center=false);

        // Remove the socket sleeve's interior so it remains a sleeve (not a solid cap),
        // matching the pipe's OD as the sleeve's inner diameter.
        translate([0, 0, len - sock_len - 2*ov])
            cylinder(h=sock_len + 4*ov, d=od, center=false);
    }
}

ht_pipe_with_socket(
    pipe_outer_diameter,
    pipe_wall_thickness,
    pipe_length,
    socket_length,
    socket_extra_diameter,
    overlap
);