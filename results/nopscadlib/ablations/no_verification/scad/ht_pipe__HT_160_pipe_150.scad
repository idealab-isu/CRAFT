// HT 160 pipe, length 150 mm (with one socket end)
// One connected solid; all placements are formula-based.

length_mm = 150;                 //[75:300:1]
ht160_outer_diameter = 160;      //[120:240:1]
ht160_wall_thickness = 4.9;      //[2.5:10:0.1]

socket_length = 60;              //[30:120:1]
socket_wall_extra = 2.5;         //[1:6:0.1]
socket_clearance = 1.0;          //[0.2:2.5:0.1]

socket_stop_thickness = 3.0;     //[1:8:0.1]
socket_stop_length = 8;          //[3:20:1]

overlap_mm = 1.0;                //[0.5:2.0:0.1]
fn = 96;                         //[24:192:1]

module ht_pipe() {
    od = ht160_outer_diameter;
    wt = ht160_wall_thickness;

    // Radii
    r_outer = od/2;
    r_inner = r_outer - wt;

    // Socket radii
    r_socket_outer = r_outer + socket_wall_extra;
    r_socket_inner = r_outer + socket_clearance;

    // Stop ring inner radius (smaller bore near socket base)
    r_stop_inner = r_socket_inner - socket_stop_thickness;

    // Safety clamps to avoid invalid/empty geometry
    eps = 0.01;
    r_inner_ok = max(eps, r_inner);
    r_stop_inner_ok = max(eps, r_stop_inner);

    // Z positions (pipe runs from z=0 to z=length_mm)
    z_pipe0 = 0;
    z_pipe1 = length_mm;

    // Socket overlaps the pipe to guarantee connectivity
    z_sock0 = z_pipe1 - overlap_mm;
    z_sock1 = z_sock0 + socket_length;

    // Stop ring occupies first part of socket (near pipe end)
    z_stop0 = z_sock0;
    z_stop1 = z_sock0 + socket_stop_length;

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER SOLID (connected)
        union() {
            // Main outer cylinder
            translate([0, 0, z_pipe0])
                cylinder(h=length_mm, r=r_outer, $fn=fn);

            // Socket outer cylinder (overlaps into main pipe)
            translate([0, 0, z_sock0])
                cylinder(h=socket_length, r=r_socket_outer, $fn=fn);
        }

        // INNER VOID (single connected subtraction)
        union() {
            // Main pipe bore
            translate([0, 0, z_pipe0 - overlap_mm/2])
                cylinder(h=length_mm + overlap_mm, r=r_inner_ok, $fn=fn);

            // Socket bore (larger) for full socket length
            translate([0, 0, z_sock0 - overlap_mm/2])
                cylinder(h=socket_length + overlap_mm, r=r_socket_inner, $fn=fn);

            // Stop region: subtract smaller bore near base so material remains as a shoulder
            translate([0, 0, z_stop0 - overlap_mm/2])
                cylinder(h=socket_stop_length + overlap_mm, r=r_stop_inner_ok, $fn=fn);
        }
    }
}

ht_pipe();