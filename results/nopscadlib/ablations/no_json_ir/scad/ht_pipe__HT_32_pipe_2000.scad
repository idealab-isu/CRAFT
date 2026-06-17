// HT 32 pipe, 2000 mm long (single connected solid)
// Fix: avoid coplanar/near-coplanar boolean surfaces that can render "blank".
// Use explicit Z extents (non-centered) and slightly different inner/outer heights.

outer_diameter = 32;      // mm
wall_thickness = 1.8;     // mm
length = 2000;            // mm

socket_len = 10;          // mm
socket_od_extra = 5;      // mm
overlap = 1.0;            // mm (guaranteed physical overlap)

eps = 0.2;                // mm (boolean robustness)
$fn = 120;

module pipe_shell_z(z0, z1, od, wt) {
    h = z1 - z0;
    difference() {
        translate([0,0,z0]) cylinder(h=h, d=od, center=false);
        // inner cut slightly longer to avoid coplanar faces
        translate([0,0,z0 - eps]) cylinder(h=h + 2*eps, d=od - 2*wt, center=false);
    }
}

module end_socket_z(z0, z1, od, od_extra, wt) {
    h = z1 - z0;
    difference() {
        // simple flared socket OD
        translate([0,0,z0]) cylinder(h=h, d1=od, d2=od + od_extra, center=false);
        // inner cut slightly longer to avoid coplanar faces
        translate([0,0,z0 - eps]) cylinder(h=h + 2*eps, d=od - 2*wt, center=false);
    }
}

module ht_pipe() {
    union() {
        // Main pipe spans [-length/2, +length/2]
        pipe_shell_z(-length/2, length/2, outer_diameter, wall_thickness);

        // End sockets overlap into main pipe by 'overlap' to ensure one connected solid
        end_socket_z(length/2 - overlap, length/2 - overlap + socket_len,
                     outer_diameter, socket_od_extra, wall_thickness);

        end_socket_z(-length/2 + overlap - socket_len, -length/2 + overlap,
                     outer_diameter, socket_od_extra, wall_thickness);
    }
}

ht_pipe();