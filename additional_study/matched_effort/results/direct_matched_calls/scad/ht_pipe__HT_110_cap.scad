$fn=180;

// HT 110 cap (approximation)
// Typical HT DN110: OD ~110mm, socket ID ~110mm, wall ~3.2mm, insertion depth ~50mm.
// This model: closed-end cap with a socket and a small external stop ring.

module ht110_cap(
    pipe_od=110.0,          // nominal pipe outside diameter
    wall=3.2,               // socket wall thickness
    insertion_depth=50.0,    // depth of socket
    end_thickness=6.0,       // thickness of closed end
    outer_extra=2.0,         // extra outer diameter beyond pipe_od for cap body
    stop_ring_height=6.0,    // external ring height near opening
    stop_ring_extra=3.0,     // extra radius for stop ring beyond cap body
    chamfer=1.2              // small chamfer at opening
){
    // Derived dimensions
    cap_outer_d = pipe_od + 2*outer_extra;
    socket_inner_d = pipe_od + 0.6; // small clearance
    socket_outer_d = socket_inner_d + 2*wall;

    // Ensure cap body outer is at least socket outer
    body_outer_d = max(cap_outer_d, socket_outer_d + 1.0);

    total_h = insertion_depth + end_thickness;

    difference() {
        union() {
            // Main outer body
            cylinder(d=body_outer_d, h=total_h);

            // External stop ring near opening
            translate([0,0,0])
                cylinder(d=body_outer_d + 2*stop_ring_extra, h=stop_ring_height);

            // Slight rounding lip at opening (small bevel-like)
            translate([0,0,0])
                cylinder(d1=body_outer_d + 0.8, d2=body_outer_d, h=chamfer);
        }

        // Socket cavity (open end)
        translate([0,0,0])
            cylinder(d=socket_inner_d, h=insertion_depth);

        // Inner relief to keep end thickness consistent (creates closed end)
        translate([0,0,insertion_depth])
            cylinder(d=socket_inner_d - 2.0, h=end_thickness + 0.2);

        // Opening chamfer inside
        translate([0,0,0])
            cylinder(d1=socket_inner_d + 2.0, d2=socket_inner_d, h=chamfer);
    }
}

ht110_cap();