// HT 50/40 T pipe (single connected solid)
// Dimension-derived placements only; guaranteed overlaps for manifold result

$fn = 160;

// Parameters (mm)
main_diameter   = 50;   // DN50 outer
side_diameter   = 40;   // DN40 outer
wall_thickness  = 2;

length_main     = 100;  // straight run length (between socket starts)
length_side     = 60;   // branch length (from run center to branch end)

socket_length   = 20;   // socket axial length
socket_extra_d  = 2*wall_thickness; // socket OD increase (simple approximation)

overlap = 0.8; // overlap to guarantee unions/differences

main_r = main_diameter/2;
side_r = side_diameter/2;

// Socket outer diameters (simple)
main_socket_d = main_diameter + socket_extra_d;
side_socket_d = side_diameter + socket_extra_d;

// Convenience: centered cylinders
module cyl_z(h, d) cylinder(h=h, d=d, center=true);
module cyl_x(h, d) rotate([0,90,0]) cylinder(h=h, d=d, center=true);

// Outer shell (connected)
module outer_shell() {
    union() {
        // Main run outer tube (along Z)
        cyl_z(length_main, main_diameter);

        // Side branch outer tube (along X, to the RIGHT)
        translate([length_side/2 - overlap, 0, 0])
            cyl_x(length_side, side_diameter);

        // DN50 sockets at both ends of main run
        translate([0, 0,  length_main/2 + socket_length/2 - overlap])
            cyl_z(socket_length, main_socket_d);

        translate([0, 0, -length_main/2 - socket_length/2 + overlap])
            cyl_z(socket_length, main_socket_d);

        // DN40 socket at end of side branch (right end)
        translate([length_side - overlap + socket_length/2, 0, 0])
            cyl_x(socket_length, side_socket_d);
    }
}

// Inner void (single connected cavity)
module inner_void() {
    union() {
        // Main bore through run + into sockets
        cyl_z(length_main + 2*socket_length + 6*overlap,
              main_diameter - 2*wall_thickness);

        // Side bore through branch + into its socket (right end)
        translate([length_side/2 - overlap, 0, 0])
            cyl_x(length_side + socket_length + 6*overlap,
                  side_diameter - 2*wall_thickness);
    }
}

// Final part
difference() {
    outer_shell();
    inner_void();
}