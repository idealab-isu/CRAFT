// HT 110 pipe segment, 150 mm long (single connected solid)
outer_diameter = 110;     // mm
wall_thickness = 3.2;     // mm
length = 150;             // mm

// End collar (ring) dimensions
collar_radial = 5;        // mm added to radius
collar_h = 6;             // mm collar height
overlap = 0.8;            // mm overlap to guarantee connectivity

$fn = 160;

module pipe_shell(h, od, t) {
    difference() {
        cylinder(h=h, d=od, center=false);
        // through-cut with margin to avoid coplanar artifacts
        translate([0, 0, -1])
            cylinder(h=h + 2, d=od - 2*t, center=false);
    }
}

module collar_solid(z0, od_outer, id_inner, h) {
    // Solid ring (not a separate shell) so union stays one connected solid
    difference() {
        translate([0, 0, z0])
            cylinder(h=h, d=od_outer, center=false);
        translate([0, 0, z0 - 1])
            cylinder(h=h + 2, d=id_inner, center=false);
    }
}

module ht_pipe() {
    od = outer_diameter;
    id = outer_diameter - 2*wall_thickness;

    collar_od = od + 2*collar_radial;
    collar_id = id; // keep bore continuous through collars

    union() {
        // Main pipe shell
        pipe_shell(length, od, wall_thickness);

        // Bottom collar: overlaps into pipe by 'overlap'
        collar_solid(0 - overlap, collar_od, collar_id, collar_h + overlap);

        // Top collar: positioned from dimensions, overlaps into pipe by 'overlap'
        collar_solid(length - collar_h, collar_od, collar_id, collar_h + overlap);
    }
}

ht_pipe();