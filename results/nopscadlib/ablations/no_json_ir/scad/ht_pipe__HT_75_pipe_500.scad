// HT 75 pipe 500 mm (single connected solid, hollow)
// Units: mm

outer_diameter = 75;      // OD
wall_thickness = 3.2;     // wall
length = 500;             // pipe length

// Simple socket/bell at one end (common for HT pipes)
socket_len = 12;
socket_extra_d = 10;      // socket OD increase over pipe OD
lip_h = 2;                // small retaining lip height
lip_extra_d = 4;          // lip OD increase over socket OD

$fn = 160;

module ht_pipe() {
    inner_d = outer_diameter - 2*wall_thickness;

    // Small epsilons to avoid coplanar/zero-thickness artifacts
    eps = 0.05;
    overlap = 1; // ensures union connection between pipe and socket

    // Z layout (all formulas, no arbitrary placement)
    z_pipe0 = 0;
    z_pipe1 = z_pipe0 + length;

    z_sock0 = z_pipe1 - overlap;
    z_sock1 = z_sock0 + socket_len + overlap;

    z_lip0  = z_sock1 - lip_h;
    z_lip1  = z_sock1;

    union() {
        // Main hollow pipe body
        difference() {
            cylinder(h=length, d=outer_diameter, center=false);
            translate([0, 0, -eps])
                cylinder(h=length + 2*eps, d=inner_d, center=false);
        }

        // Connected socket/bell at the top end (overlaps into pipe)
        translate([0, 0, z_sock0])
        difference() {
            union() {
                cylinder(h=socket_len + overlap, d=outer_diameter + socket_extra_d, center=false);
                translate([0, 0, (socket_len + overlap) - lip_h])
                    cylinder(h=lip_h, d=outer_diameter + socket_extra_d + lip_extra_d, center=false);
            }
            translate([0, 0, -eps])
                cylinder(h=(socket_len + overlap) + 2*eps, d=inner_d, center=false);
        }
    }
}

ht_pipe();