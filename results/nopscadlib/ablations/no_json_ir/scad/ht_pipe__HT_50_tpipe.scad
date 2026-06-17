// HT 50 T pipe (connected, watertight, simplified)
// One connected solid via single global difference of outer union minus inner union.

$fn = 96;

// Parameters (mm)
outer_diameter  = 50;
wall_thickness  = 3;
socket_length   = 20;
chamfer_size    = 2;

// Geometry
main_run_length = 100;   // straight-through run length (between socket mouths)
branch_length   = 50;    // branch socket length (from junction to mouth)
eps             = 0.6;   // overlap to guarantee watertight unions

inner_diameter  = outer_diameter - 2*wall_thickness;

// Outer cylinder along Z, centered
module outer_z(len, d=outer_diameter) {
    cylinder(h=len, d=d, center=true);
}

// Inner bore along Z, centered
module inner_z(len, d=inner_diameter) {
    cylinder(h=len, d=d, center=true);
}

// Inner chamfer cutter at +Z mouth for a Z-oriented socket (centered socket)
module chamfer_inner_z(len, d_inner=inner_diameter, chamfer=chamfer_size) {
    translate([0, 0, len/2 - chamfer/2])
        cylinder(h=chamfer + 0.2,
                 d1=d_inner,
                 d2=d_inner + 2*chamfer,
                 center=true);
}

module ht50_t() {
    // Derived lengths: include sockets as separate outer pieces
    main_outer_len = main_run_length + 2*socket_length;
    branch_outer_len = branch_length;

    difference() {
        // OUTER SOLID (union of shells)
        union() {
            // Main run outer
            outer_z(main_outer_len, outer_diameter);

            // Branch outer along +X, centered at origin, protruding to +X
            // Place so its -X end overlaps into main by eps
            translate([branch_outer_len/2 - eps, 0, 0])
                rotate([0, 90, 0])
                    outer_z(branch_outer_len, outer_diameter);
        }

        // INNER VOID (union of bores + chamfers)
        union() {
            // Main run bore (slightly longer to ensure clean subtraction)
            inner_z(main_outer_len + 2*eps, inner_diameter);

            // Branch bore (slightly longer)
            translate([branch_outer_len/2 - eps, 0, 0])
                rotate([0, 90, 0])
                    inner_z(branch_outer_len + 2*eps, inner_diameter);

            // Chamfers at the three mouths:
            // Main run +Z mouth
            translate([0, 0,  main_outer_len/2 - socket_length/2])
                chamfer_inner_z(socket_length, inner_diameter, chamfer_size);

            // Main run -Z mouth (flip)
            translate([0, 0, -(main_outer_len/2 - socket_length/2)])
                rotate([180, 0, 0])
                    chamfer_inner_z(socket_length, inner_diameter, chamfer_size);

            // Branch +X mouth (socket along X, so rotate chamfer module)
            translate([branch_outer_len - socket_length/2, 0, 0])
                rotate([0, 90, 0])
                    chamfer_inner_z(socket_length, inner_diameter, chamfer_size);
        }
    }
}

ht50_t();