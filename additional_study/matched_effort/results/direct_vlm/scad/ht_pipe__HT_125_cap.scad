$fn = 160;

// HT 125 cap (approximation) - hollow cap with socket, stop ring, outer rim + chamfers
// Coordinate system: open end at z=0, closed end at z=cap_depth

// Dimensions (mm)
pipe_od        = 125;   // nominal pipe OD
wall           = 3.2;   // cap wall thickness (radial)
cap_depth      = 45;    // overall height
top_thickness  = 4;     // closed end thickness

// Socket / insertion geometry
socket_depth   = 28;    // insertion depth (from open end)
socket_clear   = 0.6;   // clearance on socket ID (radius uses OD/2 + clear)
stop_h         = 3;     // internal stop ring axial height
stop_th        = 1.6;   // stop ring radial thickness (reduces ID locally)

// Outer details
outer_rim_h    = 2.2;   // radial height of outer rim/rib
outer_rim_w    = 6;     // axial width of rim
outer_rim_z    = 10;    // rim position from open end

// Chamfers / rounds (simple conical chamfers)
outer_open_ch_h = 2.0;
outer_open_ch_r = 1.2;
inner_open_ch_h = 2.0;
inner_open_ch_r = 1.2;

outer_top_ch_h  = 1.6;
outer_top_ch_r  = 1.0;

// Derived radii
pipe_od_r     = pipe_od/2;
socket_id_r   = pipe_od_r + socket_clear;          // inner socket radius
outer_r       = socket_id_r + wall;                // outer body radius

// Small overlap to avoid coincident faces
eps = 0.05;

module ht125_cap() {
    difference() {
        // OUTER SOLID (single connected body)
        union() {
            // Main outer body
            cylinder(h = cap_depth, r = outer_r);

            // Outer rim/rib (connected by construction)
            translate([0, 0, outer_rim_z])
                cylinder(h = outer_rim_w, r = outer_r + outer_rim_h);

            // Outer chamfer at open end (slight flare)
            cylinder(h = outer_open_ch_h, r1 = outer_r + outer_open_ch_r, r2 = outer_r);

            // Outer chamfer at closed end (slight taper)
            translate([0, 0, cap_depth - outer_top_ch_h])
                cylinder(h = outer_top_ch_h, r1 = outer_r, r2 = outer_r - outer_top_ch_r);
        }

        // INNER VOID: socket cavity (only to socket_depth)
        // This leaves a thicker outer shell above the socket region, like typical caps.
        translate([0, 0, 0])
            cylinder(h = socket_depth + eps, r = socket_id_r);

        // INNER VOID: upper cavity (smaller radius) to create a visible internal step/shoulder
        // Leaves closed end thickness.
        upper_void_r = max(0.5, socket_id_r - 1.2);
        translate([0, 0, socket_depth - eps])
            cylinder(h = (cap_depth - top_thickness) - socket_depth + 2*eps, r = upper_void_r);

        // Internal stop ring: reduce ID locally near bottom of socket
        // Implemented by subtracting a smaller-radius cylinder over stop_h.
        translate([0, 0, socket_depth - stop_h])
            cylinder(h = stop_h + eps, r = max(0.5, socket_id_r - stop_th));

        // Inner chamfer at opening (socket lead-in)
        cylinder(h = inner_open_ch_h, r1 = socket_id_r + inner_open_ch_r, r2 = socket_id_r);
    }
}

ht125_cap();