$fn = 128;

// Parameters (HT 50 pipe 150 mm)
nominal_diameter = 50;
length_mm = 150;
od_mm = 50;
wall_mm = 1.8;

socket_length_mm = 35;
socket_wall_extra_mm = 1.5;
socket_id_clearance_mm = 0.4;

overlap_mm = 2;          // 1-2mm overlap to guarantee union
eps = 0.02;              // epsilon to avoid coplanar faces

module ht_pipe() {
    outer_r = od_mm/2;
    inner_r = max(0.01, outer_r - wall_mm);

    socket_outer_r = outer_r + socket_wall_extra_mm;
    socket_inner_r = outer_r + socket_id_clearance_mm;

    // Main pipe spans z = [-L/2, +L/2]
    // Socket must be physically attached: overlap into main body by overlap_mm.
    // Place socket so its TOP is flush with main top (+L/2) and it extends DOWN by (socket_length + overlap).
    socket_h = socket_length_mm + overlap_mm;

    // Explicitly compute socket top/bottom to guarantee intersection with main body
    main_top_z =  length_mm/2;
    socket_top_z = main_top_z;
    socket_bottom_z = socket_top_z - socket_h;                 // extends down into main by overlap
    socket_center_z = (socket_top_z + socket_bottom_z) / 2;

    difference() {
        // OUTER: single connected solid (union)
        union() {
            // Main outer
            cylinder(h=length_mm, r=outer_r, center=true);

            // Upper sleeve/collar (socket) outer - overlaps into main body by overlap_mm
            translate([0, 0, socket_center_z])
                cylinder(h=socket_h, r=socket_outer_r, center=true);
        }

        // INNER: bores (extend slightly to ensure clean subtraction)
        union() {
            // Main inner bore
            cylinder(h=length_mm + 2*eps, r=inner_r, center=true);

            // Socket inner bore:
            // Make it slightly longer AND push it slightly downward so it fully opens the socket
            // and avoids any tiny "seam" ring from coplanar faces at the socket bottom.
            translate([0, 0, socket_center_z - eps])
                cylinder(h=socket_h + 4*eps, r=socket_inner_r, center=true);
        }
    }
}

ht_pipe();